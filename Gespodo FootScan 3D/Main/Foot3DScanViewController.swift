//
//  FootScanViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 22/01/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Foundation
import astrivis_foot3d
import astrivis_scan3d
import Alamofire
import AVFoundation
import Firebase

/*
    # Foot3DScanViewController
        This class controls the layout of the scanner and is starting
        the upload and start the download of the file to astrivis.
*/

class Foot3DScanViewController: FootScanViewController {
    //these values are set by the calling ViewController
    var store_identifier: String = ""   // helper variable set by calling ViewController
    var store_filename: String = ""     // defines the filename in the cloud, set by calling ViewController
    var store_success: Bool = false     // is set to true by this ViewController when the 3D model is successfully stored
    
    var patientHash : String = ""
    var token: String = ""
    var demoHash: String = ""
    var footScanned: String = ""
    var typeOfScan: String = ""
    let leftStr: String = "left"
    let rightStr:String = "right"
    let loadedScanStr: String = "loaded"
    let unloadedScanStr: String = "unloaded"
    let defaultFoot: String = "left"
    var num_card : String = ""
    var display_mask_name = "foot_left"
    var segmentation_mask_name = "foot_left_mask"
    var onTheMoveScan = false
    var rotated = true
    var currentFilename : Array<String> = [];
    var backgroundTaskID : UIBackgroundTaskIdentifier? = nil;
    let isMaskActivated : Bool = true
    var mirroredMask : Bool = false
    
    var boundingBoxView: ASTBoxView = ASTBoxView.init()
    var segmentation_mask: UIImage?
    var boundingBox: ASTBoundingBox?  // The computed segmentation bounding box.
    var isTrimmed: Bool = false

    @IBOutlet weak var unloadedScanButton: UIButton!
    @IBOutlet weak var loadedScanButton: UIButton!
    @IBOutlet weak var lFUnselected: UIButton!
    @IBOutlet weak var rfUnselected: UIButton!
    @IBOutlet weak var lFSelected: UIButton!
    @IBOutlet weak var rFSelected: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var bottomMiddleButton: UIButton!
    @IBOutlet weak var bottomRightButton: UIButton!
    @IBOutlet weak var surfaceButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var uncalibratedInfo: UILabel!
    @IBOutlet weak var secondScan: UIButton!
    @IBOutlet weak var flashButtonObject: UIButton!
    @IBOutlet weak var flipMask: UIButton!
    @IBOutlet weak var skipScanButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.startCameraStream()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.stopCameraStream()
    }
    
    func initScannerOptions() {
        // Hardcode tracker algorithm
        if var trackerOptions = getTrackerOptions() {
          trackerOptions.method = .improved
          setTrackerOptions(options: trackerOptions)
        }

        // Hardcode Stereo algorithm
        if var stereoOptions = getStereoOptions() {
          // consider changing to .improved, Astrivis stopped supporting
          // legacy stereo and will be removing this options in a future release.
          stereoOptions.method = .improved
          setStereoOptions(options: stereoOptions)
        }

        // Hardcode Fusion algorithm and settings
        if var fusionOptions = getFusionOptions() {
          fusionOptions.method = .surfel
          setFusionOptions(options: fusionOptions)
        }

        // Hardcode Meshing algorithm and settings
        if var meshingOptions = getMeshingOptions() {
          meshingOptions.method = .pointCloudTSDF
          meshingOptions.meshType = .legacy
          meshingOptions.tsdfNumVoxels = 128 * 128 * 128
          meshingOptions.tsdfTraceDistance = 6
          meshingOptions.meshCleanup = true
          meshingOptions.holeClosing = true
          meshingOptions.meshSmoothing = true
          meshingOptions.meshSimplification = .low
          setMeshingOptions(options: meshingOptions)
        }

        // Hardcode Texturing algorithm
        if var texturingOptions = getTexturingOptions() {
          // consider changing to .standard, Astrivis will stop supporting
          // legacy texturing soon.
          texturingOptions.method = .standard
          setTexturingOptions(options: texturingOptions)
        }
    }
    
    override func viewDidLoad() {
        
        // prevent the app from dimming the screen after timeout
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.initScannerOptions()
        
        super.viewDidLoad()
        
        
        // Ask the user for authorization to access the camera.

        super.handleCameraAuthorization(closure: { [weak self] granted in

          if (!granted) {

            DispatchQueue.main.async {

              let alert = UIAlertController.init(title: "Camera Permission Is Required",

                message: "You have denied camera permission. This app will not work without camera permission. Please go to Settings and give this app camera permission.",

                preferredStyle: .alert)

              self?.present(alert, animated: true, completion: nil)

            }

            return

          }


          self?.initCamera()

          self?.startCameraStream()

        })
        
        // Disable the back navigation gesture
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        
        // SETUP interface depending with user preference and state of scan
        if(footScanned == ""){
            footScanned = defaultFoot
        }
        
        setTypeOfScan(type : getStoredTypeOfScan())
        self.rotated = getStoredRotation()
        store_filename = createFilename()
        print("filename Created : " + store_filename)
        showCorrectFootButton()
        
        // BUTTON UI SETUP
        bottomMiddleButton.layer.cornerRadius = 15
        bottomMiddleButton.layer.masksToBounds = true
        bottomMiddleButton.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        bottomMiddleButton.layer.backgroundColor = UIColor(named: "PrimaryBG")!.cgColor
        
        
        secondScan.layer.cornerRadius = 15
        secondScan.layer.masksToBounds = true
        secondScan.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        secondScan.layer.backgroundColor = UIColor(named: "PrimaryBG")!.cgColor
        secondScan.isHidden = true
        
        
        self.skipScanButton.setTitle(NSLocalizedString("skip-scans", comment: ""), for: .normal)
        self.navigationController?.navigationBar.isHidden = true
        
        // SCAN CONFIGURATION
        ScanViewController.credentials.mKey = "Aejoo3quiech3Aey8cheechei4eeL5vo";
        ScanViewController.credentials.mUrl = "https://upload.astrivis.com/gespodo/api/upload/model";
        
        self.setShowMask(true)
        switchState(newState: .idle)
        
    }
    
    override func onTroideeReady() {
        super.onTroideeReady()
        addView(view: boundingBoxView)
        manageMask(whichFeet: self.footScanned, rotate: self.rotated, mirror : self.mirroredMask)
    }
            
    /*
     Function to select the type of scan (unload scan or loaded scan)
     */
    
    func getStoredTypeOfScan() -> String {
        let defaults: UserDefaults? = UserDefaults.standard
        return (defaults?.value(forKey: "typeOfScan") ?? self.unloadedScanStr) as! String
    }
    
    func getStoredRotation() -> Bool {
        let defaults: UserDefaults? = UserDefaults.standard
        return (defaults?.value(forKey: "rotated") ?? self.rotated) as! Bool
    }
    
    func setTypeOfScan(type: String){
        typeOfScan = type
        loadedScanButton.isHidden = typeOfScan == unloadedScanStr
        unloadedScanButton.isHidden = !loadedScanButton.isHidden
        
        if(typeOfScan == unloadedScanStr){
            self.mirroredMask = false
            manageMask(whichFeet: self.footScanned, rotate: self.rotated, mirror: self.mirroredMask)
        }else {
            self.mirroredMask = true
            manageMask(whichFeet: self.footScanned, rotate: self.rotated, mirror: self.mirroredMask)
        }
    }
    
    
    @IBAction func skipScanButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "footScanIsFinnished", sender: self)
    }
    
    
    @IBAction func setTypeOfScanButtonPressed(_ sender: Any) {
        
        setTypeOfScan(type: typeOfScan == self.unloadedScanStr ? self.loadedScanStr : self.unloadedScanStr)
                
        store_filename = createFilename()
                
        UserDefaults.standard.set(typeOfScan ,forKey: "typeOfScan")
    }
    
    
    @IBAction func flippingMask(_ sender: Any) {
        manageMask(whichFeet: self.footScanned, rotate: !self.rotated , mirror : self.mirroredMask)
        self.rotated = !self.rotated
        UserDefaults.standard.set(self.rotated, forKey: "rotated")

    }
    
    func manageMask(whichFeet : String , rotate : Bool, mirror : Bool){
        // unloaded = mirror false
        if(!mirror){
            switch whichFeet {
                case self.leftStr:
                    display_mask_name = "foot_left"
                    segmentation_mask_name = "foot_left_mask"
                case self.rightStr:
                    segmentation_mask_name = "foot_right_mask"
                    display_mask_name = "foot_right"
            default :
                display_mask_name = "foot_left"
                segmentation_mask_name = "foot_left_mask"
            }
        }else{
            switch whichFeet {
                case self.leftStr:
                    segmentation_mask_name = "foot_right_mask"
                    display_mask_name = "foot_right"
                case self.rightStr:
                    display_mask_name = "foot_left"
                    segmentation_mask_name = "foot_left_mask"
            default :
                segmentation_mask_name = "foot_right_mask"
                display_mask_name = "foot_right"
            }
        }
        //if(self.typeOfScan == self.loadedScanStr){
        //    display_mask_name = "mask_rectangle"
        //}
        
        
        var display_mask = UIImage(named: display_mask_name)
        self.segmentation_mask = UIImage(named: segmentation_mask_name)
        
        if(rotate){
            display_mask = display_mask?.rotate(radians: .pi)
            self.segmentation_mask = segmentation_mask?.rotate(radians: .pi)
        }
        
        setDisplayMask(mask: display_mask ) //rotate by 180 degrees
    }
    
    
    func scanFeet( whichFeet : String){
        self.footScanned = whichFeet
        if(self.isMaskActivated){
            manageMask(whichFeet: whichFeet, rotate: self.rotated , mirror: self.mirroredMask)
        }
    }
    
    @IBAction func wichFeetIsScanned(_ sender: Any) {
        
        lFSelected.isHidden = lFUnselected.isHidden
        lFUnselected.isHidden = !lFUnselected.isHidden
        
        rFSelected.isHidden = rfUnselected.isHidden
        rfUnselected.isHidden = !rfUnselected.isHidden
        
        if !lFSelected.isHidden {
            scanFeet(whichFeet: self.leftStr)
        }else{
            scanFeet(whichFeet: self.rightStr)
        }
        store_filename = createFilename()
        print("WHICH FOOT ", store_filename)
    }
    
    func scanOtherFeet(){
        if(footScanned == leftStr){
            scanFeet(whichFeet: self.rightStr)
        }else{
            scanFeet(whichFeet: self.leftStr)
        }
        store_filename = createFilename()
        showCorrectFootButton()
        self.reset(loadPrefs : true)
        self.setShowMapPoints(true);
    }
    
    //hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func createPictureFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM-dd-HH-mm-ss"
        return "Foot-Scan-Picture-" + num_card + "-" + dateFormatter.string(from: Date())
        
    }
    
    func createFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM-dd-HH-mm-ss"
        return "Foot-Scan" + "-" + num_card + "-" + footScanned + "-" + typeOfScan + "-" + dateFormatter.string(from: Date())
    }
    
    func showCorrectFootButton(){
        if(footScanned == leftStr){
            lFSelected.isHidden = false
            lFUnselected.isHidden = true
            rFSelected.isHidden = true
            rfUnselected.isHidden = false
        }else{
            lFSelected.isHidden = true
            lFUnselected.isHidden = false
            rFSelected.isHidden = false
            rfUnselected.isHidden = true
        }
    }
    
    //Asks the user via an Alert if the model should be reset. If yes, returns true in the completion handler
    func askIfReallyReset(completion: @escaping (_: Bool) -> Void){
        let alert = UIAlertController(title: NSLocalizedString("Réinitialisation du Scanner", comment: ""),
                                      message: NSLocalizedString("Ceci effacera le model en cours de scan, êtes vous sûr de vouloir le supprimer?", comment: ""),
                                      preferredStyle: .alert)
        let noAction = UIAlertAction(title: NSLocalizedString("Non, annuler", comment: ""), style: .cancel) { _ in
            completion(false)
        }
        alert.addAction(noAction)
        let yesAction = UIAlertAction(title: NSLocalizedString("Oui", comment: ""), style: .destructive) { _ in
            completion(true)
        }
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UI
    @IBAction func bottomMiddleButtonPressed(_ sender: Any) {
        startButtonPressed();
    }
    
    @IBAction func startANewScan(_ sender: Any) {
        saveAndUploadScan(isScanFinished: false)
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        super.swapCameras()
    }
    
    /*
        Save the scan and upload it to Astrivis
        If the segmentation box is visible. Also uplaod a
        trimmed version of the scan
     */
    
    func saveAndUploadScan(isScanFinished : Bool) {
        //show an alert with spinning indicator while model is being stored
        let alert = UIAlertController(title: NSLocalizedString("Sauvegarde du modèle...", comment: "") + "\n", message: "", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        let views: [String : UIView] = ["alert" : alert.view, "indicator" : indicator]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-15-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|",
                                                      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                      metrics: nil, views: views)
        alert.view.addConstraints(constraints)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        self.present(alert, animated: true, completion: nil)
        // Move to a background thread to do some long running work
        Analytics.logEvent("uploading_stl_to_astrivis", parameters: [
            "fileName": self.store_filename as NSObject
            ])
        
        func download(filename: String, trimming : Bool){
            if(trimming){
                guard let boundingBox = self.boundingBox else { return }
                trimScan(boundingBox: boundingBox)
                isTrimmed = true
            }
            self.storeModel(email: "", modelName: filename , multiPart: true)
            self.syncModels(usingMobileData: true ,modelFinished: { (modelName: String) -> Void in
                print("Model successfully transfered: \(modelName)")
                Analytics.logEvent("uploaded_stl_to_astrivis", parameters: [
                    "fileName": modelName as NSObject
                    ])
                let queueOne = DispatchQueue(label: "com.gespodo.footscan.3D.download.model")
                queueOne.sync(flags: .barrier) {
                    self.fetchFile(fileName: modelName)
                }
            }, uploadError: { (errorString, SyncError)->Void in
                print("ERROR during the upload", errorString , SyncError)
                Utils.displayErrorMessage(message: NSLocalizedString("L'erreur suivante est survenue pendant l'upload de votre fichier ", comment: "") + errorString , viewController: self)
                Analytics.logEvent("uploaded_stl_to_astrivis", parameters: [
                    "fileName": filename as NSObject,
                    "error" : true,
                    "message": errorString
                    ])
            })
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if(self.onTheMoveScan){
               self.store_filename = self.store_filename + "_" + self.patientHash
            }
            // Start the transfer of the stl (if bouding box, start a second upload with the trimmed file)
            download(filename: self.store_filename, trimming: false)
            download(filename: "trimmed-" + self.store_filename , trimming: true)
            
                                
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    //go back to MainViewController and inform that store successful
                    self.store_success = true;
                    if(isScanFinished){
                        self.performSegue(withIdentifier: "footScanIsFinnished", sender: self)
                    }else{
                        self.scanOtherFeet()
                    }
                })
            }
        }
    }
    

    

    
    @IBAction func bottomRightButtonPressed(_ sender: Any) {
        switch state {
        case .denseDone:
            startMeshing()
        case .finished:
            saveAndUploadScan(isScanFinished : true)
            return
        default:
            return
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        askIfReallyReset(completion: {
            (wantsToReset) in
            if(wantsToReset) {
                self.skipScanButton.isHidden = false
                self.reset(loadPrefs: true)
                self.setShowMapPoints(true)
                self.setShowMask(true)
                self.isTrimmed = false
                self.boundingBoxView.setVisible(status: false)
            }
        })
    }
    
    @IBAction func surfaceButtonPressed(_ sender: Any) {
              
        
        let isBoxVisible: Bool = boundingBoxView.isVisible()
        if (!isTrimmed) {
          // This check if just for the demonstration implementation, the box does not
          // need to be shown for scaling or trimming to work.
          if (!isBoxVisible) {
            // Example implementation: First compute segmentation bounding box and
            // make it visible.
            guard let mask = segmentation_mask else { return }
            let options: String = getSegmentationDefaultOptions()
            computeSegmentationBoundingBox(options: options, mask: mask,
                                           onFinished: {(boundingBox: ASTBoundingBox?) -> Void in
                                            // If the computation failed, the returned bounding box is nil.
                                            // This means that the scanned 3D model is incomplete or bad.
                                            // Show error message to user and offer an option to reset the scan
                                            // and try again.
                                            self.boundingBox = boundingBox
                                            guard let boundingBox = self.boundingBox else {
                                                // Inform user.
                                                let alert = UIAlertController(title: NSLocalizedString("Erreur de segmentation", comment: ""),
                                                                              message: NSLocalizedString("Le scan est incomplet. Veuillez annulez le scan et recommencez.", comment: ""),
                                                                              preferredStyle: .alert)
                                                let noAction = UIAlertAction(title: "OK", style: .cancel) { _ in
                                                    return
                                                }
                                                alert.addAction(noAction)
                                                
                                                DispatchQueue.main.async(execute: {() -> Void in
                                                    self.present(alert, animated: true, completion: nil)
                                                })
                                                
                                                // Stop here.
                                                return
                                            }
                                            
                                            self.boundingBoxView.setFrom(boundingBox: boundingBox)
                                            self.boundingBoxView.setVisible(status: true)
            })
            
          } else {
            // Example implementation: second tap on the trimButton trims the mesh.
            // trimScan() must only be called after computeSegmentationBoundingBox()
            guard let boundingBox = self.boundingBox else { return }
            trimScan(boundingBox: boundingBox)
            isTrimmed = true
          }
        } else {
          // Example implementation: after trimming the bounding box can be toggled.
          boundingBoxView.setVisible(status: !isBoxVisible)
        }
        requestRender()
    }
    
    override func switchState(newState: ASTScanState) {
        super.switchState(newState: newState)
        DispatchQueue.main.async(execute: {() -> Void in
            self.updateUIToMatchState()
        })
    }
    
    func updateUIToMatchState() {
        switch state {
        case .idle:
            bottomRightButton.isHidden = true
            resetButton.isHidden = true
            bottomMiddleButton.isHidden = false
            bottomMiddleButton.setTitle("Scan", for: .normal)
            surfaceButton.isHidden = true
            progressBar.isHidden = true
            progressBar.setProgress(0, animated: false)
            secondScan.isHidden = true
            flipMask.isHidden = false
            showCorrectFootButton()
            scanFeet(whichFeet: self.footScanned)
        case .scanning:
            setDisplayMask(mask: nil)
            bottomRightButton.isHidden = true
            resetButton.isHidden = false
            resetButton.setTitle("Reset", for: .normal)
            bottomMiddleButton.isHidden = false
            bottomMiddleButton.setTitle(NSLocalizedString("Terminer", comment: ""), for: .normal)
            surfaceButton.isHidden = true
            progressBar.isHidden = true
            lFUnselected.isHidden = true
            rfUnselected.isHidden = true
            skipScanButton.isHidden = true
            lFSelected.isHidden = true
            rFSelected.isHidden = true
        case .waitForDenseDone:
            bottomRightButton.isHidden = true
            resetButton.isHidden = false
            resetButton.setTitle("Reset", for: .normal)
            bottomMiddleButton.isHidden = true
            bottomMiddleButton.setTitle("Resume", for: .normal)
            surfaceButton.isHidden = true
            flipMask.isHidden = true
            progressBar.isHidden = false
        case .denseDone:
            bottomRightButton.isHidden = false
            bottomRightButton.setTitle("Mesh", for: .normal)
            resetButton.isHidden = false
            resetButton.setTitle("Reset", for: .normal)
            bottomMiddleButton.isHidden = true
            bottomMiddleButton.setTitle("Resume", for: .normal)
            surfaceButton.isHidden = true
            progressBar.isHidden = true
            progressBar.setProgress(0, animated: false)
        case .waitForMeshDone:
            bottomRightButton.isHidden = true
            resetButton.isHidden = false
            resetButton.setTitle("Reset", for: .normal)
            bottomMiddleButton.isHidden = true
            surfaceButton.isHidden = true
            progressBar.isHidden = false
        case .waitForTextureDone:
            bottomRightButton.isHidden = true
            resetButton.isHidden = false
            resetButton.setTitle("Reset", for: .normal)
            bottomMiddleButton.isHidden = true
            surfaceButton.isHidden = false
            progressBar.isHidden = false
        case .finished:
            bottomRightButton.setTitle("Save", for: .normal)
            bottomRightButton.isHidden = false
            resetButton.isHidden = false
            resetButton.setTitle("Reset", for: .normal)
            bottomMiddleButton.isHidden = true
            surfaceButton.isHidden = false
            progressBar.isHidden = true
            progressBar.setProgress(0, animated: false)
            secondScan.isHidden = false
        @unknown default:
            Analytics.logEvent("unknow_updateUIToMatchState", parameters: ["state": state])
        }
    }
    
    override func updateProgress() {
        let progress = getProgress()
        switch state {
        case .waitForDenseDone:
            DispatchQueue.main.sync(execute: {() -> Void in
                progressBar.setProgress(progress, animated: false)
            })
        case .waitForMeshDone:
            DispatchQueue.main.sync(execute: {() -> Void in
                progressBar.setProgress(progress, animated: false)
            })
        case .waitForTextureDone:
            DispatchQueue.main.sync(execute: {() -> Void in
                progressBar.setProgress(progress, animated: false)
            })
        default:
            break;
        }
    }
    
    func displayHelpMessage() {
        let alertView = UIAlertController(title: NSLocalizedString("Menu d'aide", comment: ""), message: NSLocalizedString("Premier message d'aide", comment: ""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    
    func displayPopupMessage(message : String , type: Int) {
        let alertView = UIAlertController(title: NSLocalizedString("Attention!", comment: ""), message: message, preferredStyle: .alert)
        if(type == 1){
            let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
            }
            alertView.addAction(OKAction)
        }else if(type == 2){
            let cancelAction =  UIAlertAction(title: NSLocalizedString("Annuler", comment: ""), style: .default) { (action:UIAlertAction) in
            }
            
            let refuseAction = UIAlertAction(title: NSLocalizedString("Refuser", comment: ""), style: .default) { (action:UIAlertAction) in
                
                self.performSegue(withIdentifier: "gdprRefused", sender: self)
            }
            alertView.addAction(cancelAction)
            alertView.addAction(refuseAction)
        }
        
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    
    @IBAction func openHelpMenu(_ sender: Any) {
        
        
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! CustomAlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    /*
        The process of downloading a file from Astrivis is done in two steps :
            - first we retreive the hash from the Astrivis server
            - the file is downloaded with the help of the hash retreived at the previous
     */
    
    func fetchFile(fileName: String , counter : Int = 0){
        var scan_hash : String = ""
        //Fetch the file from Astrivis
        DispatchQueue.global(qos: .utility).async {
            
            let parameters: Parameters = [
                "key": "xoadieHae5iF0ChieZoowaes2sho2ep3",
                "filename": fileName
            ]
            
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
               // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
            
            Alamofire.request(Utils.getApiAddress(key: Utils.ASTRIVIS_DOWNLOAD_URL), method: .post, parameters: parameters,encoding: JSONEncoding.default)
                .responseJSON { response in
                    
                    if let result = response.result.value {
                    let JSONARRAY = result as! Array<Any>
                    let firstResult = JSONARRAY[0] as! Array<Any>
                    if(firstResult.count > 0){
                        let JSON = firstResult[0] as! Dictionary<String,Any>
                        let formatsArray = JSON["formats"] as! Array<Any>
                        let formatsJSON = formatsArray[0] as! Dictionary<String,Any>
                        scan_hash =  formatsJSON["hash"] as! String
                                                
                        Analytics.logEvent("fetching_file", parameters: [
                            "fileName": fileName,
                            "result" : "SUCESS"
                            ])
                        self.downloadFile(filename: fileName, hash_astrivis: scan_hash)
                    }else{

                        Analytics.logEvent("fetching_file", parameters: [
                            "fileName": fileName,
                            "result" : firstResult
                            ])
                        if(counter <= 20){
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                                self.fetchFile(fileName: fileName, counter: counter + 1)
                            })
                            
                        }else{
                            Analytics.logEvent("fetching_file", parameters: [
                                "fileName": fileName,
                                "result" : "Failed to fetch. Tried \(counter) times"
                                ])
                            
                            Utils.displayErrorMessage(message: NSLocalizedString("Une erreur est survenue lors du téléversment de votre fichier. Veuillez contacter Gespodo pour reporter cette erreur.", comment: ""), viewController: self)
                        }
                    }
                }
                    
            }
        }
    }
    
    
    /*
     
     */
    func downloadFile (filename: String , hash_astrivis: String){
        print("Downloading the file " , filename, " from Astrivis")
            let downloadParameters: Parameters = [
                "key":"xoadieHae5iF0ChieZoowaes2sho2ep3",
                "hash": hash_astrivis
            ]
            
            Alamofire.request(Utils.getApiAddress(key: Utils.ASTRIVIS_DOWNLOAD_FILE_URL), method: .post, parameters: downloadParameters, encoding: JSONEncoding.default).responseJSON { response in
                
                if let result = response.result.value{
                    let data = result as! NSDictionary
                    var baseData = data["data"] as! String
                    let remainder = baseData.count % 4
                    if remainder > 0 {
                        baseData = baseData.padding(toLength: baseData.count + 4 - remainder,
                                                    withPad: "A",
                                                    startingAt: 0)
                    }
                    let decodedData = Data(base64Encoded: baseData)!
                    let format = data["format"] as! String
                    let file = filename + "." + format //this is the file. we will write to and read from it
                    let text = decodedData //just a text
                    self.currentFilename.append(filename)
                    print("--- \(file) has been downloaded---")
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        Analytics.logEvent("downloading_stl_from_astrivis", parameters: [
                            "fileName": filename,
                            "result" : "SUCCESS"
                            ])
                        
                        let fileURL = dir.appendingPathComponent(file)
                        //writing
                        do {
                            try text.write(to: fileURL)
                        }
                        catch {
                            Analytics.logEvent("downloading_stl_from_astrivis", parameters: [
                                "fileName": filename,
                                "result" : "Error while saving the downloaded stl : \(error)"
                                ])
                        }
                        do {
                            print("UPLOAD TO WEBDIGIT")
                            try self.uploadToWebdigit(filename: filename , fileURL: fileURL)
                            
                        }catch uploadError.invalidFileName(let currentFilename , let filename) {
                            Analytics.logEvent("uploading_stl_to_web", parameters: [
                                "fileName": filename,
                                "result" : "The file \(filename) is not the current file that is named: \(currentFilename)"
                                ])
                        }catch{
                            print("\(error)")
                        }
                    }
                }else{
                    Analytics.logEvent("downloading_stl_from_astrivis", parameters: [
                        "fileName": filename,
                        "result" : "failed"
                        ])
                }
            }
    }
    
    enum uploadError : Error{
        case invalidFileName(currentFilename : String , invalidFilename : String)
    }
    
    /*
      Once the file has been downloaded, it can be uploaded to the web platform
     */
    func uploadToWebdigit(filename: String, fileURL : URL) throws{
        if(!self.currentFilename.contains(filename)){
            print("WEBDIGIT ARRAY FILES", self.currentFilename,"Filename", filename)
            print("WEBDIGIT NOT SAME FILE NAME")
            throw uploadError.invalidFileName(currentFilename: self.store_filename, invalidFilename: filename)
        }
        
        let headers: HTTPHeaders = [
            "x-Auth-Token": self.token
        ]
        var URL = ""
        if(self.onTheMoveScan){
            URL = Utils.getApiAddress(key: Utils.API_UPLOAD_WAITING_LIST_PART_1) + self.patientHash + Utils.getApiAddress(key: Utils.API_UPLOAD_WAITING_LIST_PART_2)
        }else{
            URL = Utils.getApiAddress(key: Utils.API_URL_UPLOAD_STL_PRO_PART_1) + self.patientHash + Utils.getApiAddress(key: Utils.API_URL_UPLOAD_STL_PRO_PART_2)
        }
                
        Alamofire.upload(
            multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "files[]")
            },
            usingThreshold: UInt64.init(),
            to: URL,
            method: .post,
            headers: headers,
            encodingCompletion:{ result in
                switch result {
                case .success(let upload , _ , _):
                    upload.responseJSON{
                        response in
                        print("File uploaded to webdigit", response)
                         Analytics.logEvent("uploading_stl_to_web", parameters: [
                            "fileName": filename,
                            "result" : "SUCESS :  \(response.result.value as? String ?? "")"
                            ])
                        UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                        self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                    }
                case .failure(let encodingError):
                    print("File uploaded Error", encodingError)
                    Analytics.logEvent("uploading_stl_to_web", parameters: [
                        "fileName": filename,
                        "result" : "Upload failed with code : \(encodingError)"
                        ])
                    Utils.displayErrorMessage(message: NSLocalizedString("Une erreur est survenue lors de l'upload de votre fichier sur nos serveur, merci de contacter le service de Gespodo afin de leur signaler le problème.", comment: ""), viewController: self)
                    UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                    self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                }
                
        })

    }
    
    @IBAction func flashButton(_ sender: UIButton) {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            
            if (device.hasTorch) {
                do {
                    try device.lockForConfiguration()
                    let torchOff = !device.isTorchActive
                    try device.setTorchModeOn(level: 1.0)
                    device.torchMode = torchOff ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
                    
                    device.unlockForConfiguration()
                    if(!torchOff){
                        // "Flash is on"
                        let lightIm : UIImage = UIImage(named: "ic_light")!
                        sender.setImage(lightIm, for: .normal)
                    }else{
                        // "Flash is off"
                        let activeIm : UIImage = UIImage(named: "ic_light_active")!
                        sender.setImage(activeIm , for: .normal)
                    }
                 } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is AddPictureViewController
        {
            let vc = segue.destination as? AddPictureViewController
            if !Utils.getDemo() {
                vc?.patientHash = self.patientHash
                vc?.token = self.token
                vc?.fileName = self.createPictureFilename()
                vc?.onTheMoveScan = self.onTheMoveScan
            }else{
                vc?.demoHash = self.demoHash
            }
        }
    }
}

extension Foot3DScanViewController: CustomAlertViewDelegate {
    
    func okButtonTapped(selectedOption: String, textFieldValue: String) {
    }
    
    func cancelButtonTapped() {
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

