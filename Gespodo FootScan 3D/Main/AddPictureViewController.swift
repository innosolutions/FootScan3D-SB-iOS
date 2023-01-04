//
//  AddPictureViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 30/01/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Alamofire

class AddPictureViewController: UIViewController, UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    var scanProperties: [String] = []
    var patientHash : String = ""
    var token: String = ""
    var fileName: String = ""
    var fileNameExt : String = ""
    var demoHash: String = ""
    var onTheMoveScan = false
    @IBOutlet weak var pictureUploaded: UITextView!
    var numberOfImage: Int = 0;
    @IBOutlet weak var skip: UIButton!
    @IBOutlet weak var addPictureText: UITextView!
    @IBOutlet weak var addAnotherScan: UIButton!
    @IBOutlet weak var takeAPictureButton: UIButton!
    @IBOutlet weak var equipmentPictureButton: UIButton!
    @IBOutlet weak var prescriptionPictureButton: UIButton!
    @IBOutlet weak var pedigraphyPictureButton: UIButton!
    @IBOutlet weak var footPictureButton: UIButton!
    @IBOutlet weak var takeVideoButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPictureText.text = NSLocalizedString("Ajouter un ou plusieurs document à votre dossier patient (Pédigraphie, empreinte 2D, photos,...)", comment: "")
        Utils.addGradientToView(view: self.view)
        skip.layer.cornerRadius = 15
        skip.layer.masksToBounds = true
        skip.layer.borderWidth = 1
        skip.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        
        
        self.buttonSetup()
    }
    @IBAction func endScan(_ sender: Any) {
        if(Utils.getDemo()){
            self.performSegue(withIdentifier: "endScanDemo", sender: self)
        }else{
            self.performSegue(withIdentifier: "endScan", sender: self)
        }
        
    }
    
    
    var imagePicker: UIImagePickerController!
    @IBAction func takePhoto(_ sender: Any) {
        self.fileNameExt = "-other-"
        self.startCameraScreen()
    }
    
    
    @IBAction func takePrescriptionPhoto(_ sender: Any) {
        self.fileNameExt = "-prescription-"
        self.startCameraScreen()
    }
    
    @IBAction func takeEquipmentPhoto(_ sender: Any) {
        self.fileNameExt = "-equipment-"
        self.startCameraScreen()
    }
    
    @IBAction func takePedigraphyPhoto(_ sender: Any){
        self.fileNameExt = "-pedigraphy-"
        self.startCameraScreen()
    }
    
    @IBAction func takeFootPhoto(_ sender: Any){
        self.fileNameExt = "-foot-"
        self.startCameraScreen()
    }
    
    private func buttonSetup(){
        addAnotherScan.layer.cornerRadius = 15
        addAnotherScan.layer.masksToBounds = true
        addAnotherScan.layer.borderWidth = 1
        addAnotherScan.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        takeAPictureButton.layer.cornerRadius = 15
        takeAPictureButton.layer.masksToBounds = true
        takeAPictureButton.layer.borderWidth = 1
        takeAPictureButton.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        equipmentPictureButton.layer.cornerRadius = 15
        equipmentPictureButton.layer.masksToBounds = true
        equipmentPictureButton.layer.borderWidth = 1
        equipmentPictureButton.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        prescriptionPictureButton.layer.cornerRadius = 15
        prescriptionPictureButton.layer.masksToBounds = true
        prescriptionPictureButton.layer.borderWidth = 1
        prescriptionPictureButton.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        pedigraphyPictureButton.layer.cornerRadius = 15
        pedigraphyPictureButton.layer.masksToBounds = true
        pedigraphyPictureButton.layer.borderWidth = 1
        pedigraphyPictureButton.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        
        footPictureButton.layer.cornerRadius = 15
        footPictureButton.layer.masksToBounds = true
        footPictureButton.layer.borderWidth = 1
        footPictureButton.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        
        
        self.takeAPictureButton.setTitle(NSLocalizedString("other-picture", comment: ""), for: .normal)
        self.equipmentPictureButton.setTitle(NSLocalizedString("take-equipment-picture", comment: ""), for: .normal)
        self.prescriptionPictureButton.setTitle(NSLocalizedString("take-prescription-picture", comment: ""), for: .normal)
        self.pedigraphyPictureButton.setTitle(NSLocalizedString("take-pedigraphy-picture", comment: ""), for: .normal)
        self.footPictureButton.setTitle(NSLocalizedString("take-foot-picture", comment: ""), for: .normal)
        
        self.skip.setTitle(NSLocalizedString("Terminer", comment: ""), for: .normal)
    }
    
    func startVideoScreen(){
        
        VideoService.instance.launchVideoRecorder(in: self, completion: nil)

    }
    
    
    func startCameraScreen(){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
            }
        
        self.numberOfImage = self.numberOfImage + 1 ;
        let message = NSLocalizedString("Le nombre de photos suivant va être téléchargé sur la plateforme : ", comment: "") + String(self.numberOfImage)
        self.pictureUploaded.text =  message
        self.pictureUploaded.isHidden = false

//        saveImage(imageName: "test.jpg", image: image)
//        getImage(imageName: "test.jpg")
        if(!Utils.getDemo()){
            uploadImage(image: image)
        }
        
    }
    
    func saveImage(imageName: String, image : UIImage){
        //create an instance of the FileManager
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //get the PNG data for this image
        let data = image.jpegData(compressionQuality:1)!
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)

    }
    
    func getImage(imageName: String){
        
        let fileManager = FileManager.default
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        if fileManager.fileExists(atPath: imagePath){
            let image: UIImage = UIImage(contentsOfFile: imagePath)!
            uploadImage(image: image)
        }else{
            print("Panic! No Image!")
        }
    }
    
    
    func uploadImage(image : UIImage){
        let data = image.jpegData(compressionQuality:0.1)!
        
        
        let headers: HTTPHeaders = [
            "x-Auth-Token": self.token
        ]
        var URL = ""
        if(self.onTheMoveScan){
            URL = Utils.getApiAddress(key: Utils.API_UPLOAD_WAITING_LIST_PART_1) + self.patientHash + Utils.getApiAddress(key: Utils.API_UPLOAD_WAITING_LIST_PART_2)
        }else{
            URL = Utils.getApiAddress(key: Utils.API_URL_UPLOAD_STL_PRO_PART_1) + self.patientHash + Utils.getApiAddress(key: Utils.API_URL_UPLOAD_STL_PRO_PART_2)
        }
                        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data ,withName: "files[]", fileName: self.fileName + self.fileNameExt + String(self.numberOfImage) + ".jpg", mimeType: "image/jpg")
        }, usingThreshold: UInt64.init(), to: URL, method: .post, headers: headers) { response in
            print(response)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is Foot3DScanViewController{
            let vc = segue.destination as? Foot3DScanViewController
            
            vc?.patientHash = self.patientHash
            vc?.token = self.token
        }else if segue.destination is DemoEndScanViewController{
            let vc = segue.destination as? DemoEndScanViewController
            vc?.demoHash = self.demoHash
            
        }else if segue.destination is EndScanViewController{
            let vc = segue.destination as? EndScanViewController
            if(onTheMoveScan){
                vc?.onTheMove = onTheMoveScan
            }else{
                vc?.num_hash = self.patientHash
            }
        }
        
    }

}

