//
//  QRScannerViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 17/01/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var result: [String] = []
    @IBOutlet weak var QRCodeDisplay: UIView!
    @IBOutlet weak var introText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        introText.text = NSLocalizedString("Scannez le QR code fournis sur la plateforme Gespodo pour commencer le scan", comment: "")
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        Utils.addGradientToView(view: self.view)
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        do{
            try videoCaptureDevice.lockForConfiguration()
            if (videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus)){
                videoCaptureDevice.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
            }            
            videoCaptureDevice.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            videoCaptureDevice.unlockForConfiguration()
        }catch{
            print("ERROR WHEN CONFIGURATING THE QR CODE")
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        QRCodeDisplay.layer.cornerRadius = 15
        QRCodeDisplay.layer.masksToBounds = true
        previewLayer.frame = QRCodeDisplay.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
        QRCodeDisplay.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(QRCodeDisplay)
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: NSLocalizedString("Scan non supporté", comment: ""), message: NSLocalizedString("Your device does not support scanning a code from an item. Please use a device with a camera.", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        //TODO send the code to the next view? Or Store the information using a static class ?
        // This could be done in android As Well.
        
        // Then we should ask for the permission to use the photos of the patient
        // and after that the astrivis scanner could be finally launch !

        result = Utils.decodeQrCode(code: code)
        if(self.result.count > 0){
            if(!result[0].isEmpty && !result[1].isEmpty){
                self.performSegue(withIdentifier: "gdprAcceptation", sender: self)
            }
        }else{
            // Popup saying that the QR code is not valid + giving the opportunity to restart the scan
            self.displayErrorMessage(message: NSLocalizedString("QR code invalide. Veuillez scanner un QR code correct", comment: ""))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GdprViewController
        {
            let vc = segue.destination as? GdprViewController
            
            vc?.patientHash = result[1]
            vc?.token =  result[0]
            vc?.num_card = result[2]

        }
    }
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: NSLocalizedString("Erreur", comment: ""), message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
            self.viewDidLoad()
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }

    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
