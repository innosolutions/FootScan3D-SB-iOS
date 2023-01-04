//
//  GDPRViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 04/03/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Alamofire

class GdprViewController: UIViewController {
    var token: String = ""
    var patientHash: String = ""
    var num_card: String = ""
    var onTheMoveScan : Bool = false
    
    @IBOutlet weak var decline_button: UIButton!
    @IBOutlet weak var accept_Button: UIButton!
    @IBOutlet weak var gdprText1: UITextView!
    @IBOutlet weak var gdprTextAcceptMandatory: UITextView!
    @IBOutlet weak var gdprTextEmail: UITextView!
    @IBOutlet weak var gdprTextEmail2: UITextView!
    
    @IBOutlet weak var emailSwitch: UISwitch!
    
    @IBOutlet weak var descriptionEmail: UITextView!

    @IBOutlet weak var emailDescription2: UITextView!
    @IBOutlet weak var mandatoryGDPRSwitch: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decline_button.layer.cornerRadius = 15
        decline_button.layer.masksToBounds = true
        accept_Button.layer.cornerRadius = 15
        accept_Button.layer.masksToBounds = true
        
        gdprText1.text = NSLocalizedString("La vie privée de votre patient nous tient à coeur. Pour répondre aux exigences du RGPD, veuillez recueillir son consentement :", comment: "")
        gdprTextAcceptMandatory.text = NSLocalizedString("Pour la conception et la fabrication 3D de ses semelles", comment: "")
        gdprTextEmail.text = NSLocalizedString("Pour le suivi médical de son traitement (email de suivi à 6 et 12 semaines)", comment: "")
        gdprTextEmail2.text = NSLocalizedString("Pour que le patient reçoive ses emails de suivi, veuillez entrer son email :", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap) // Add gesture recognizer to background view

        
        //        Move view when keyboard open or close
//        NotificationCenter.default.addObserver(self, selector: #selector(GdprViewController.keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(GdprViewController.keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)

        let emailPlaceholder = NSAttributedString(string: NSLocalizedString("Email" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.emailField.attributedPlaceholder = emailPlaceholder
        self.emailField.textColor = .darkGray   
        self.emailField.delegate = self

    }

    
    @objc func handleTap() {
        emailField.resignFirstResponder() // dismiss keyoard
    }
    
//    move view with keyboard
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//      guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//      else {
//        // if keyboard size is not available for some reason, dont do anything
//        return
//      }
//        print("view origin ", self.view.frame.origin.y)
//        if self.view.frame.origin.y == 92{
//            self.view.frame.origin.y -= keyboardSize.height
//        }
//
//
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//        else {
//          // if keyboard size is not available for some reason, dont do anything
//          return
//        }
//
//        if self.view.frame.origin.y != 0{
//            self.view.frame.origin.y += keyboardSize.height
//        }
//    }
    
    @IBAction func followingOfThePatient(_ sender: UISwitch) {
        descriptionEmail.isHidden = !emailSwitch.isOn
        emailField.isHidden = !emailSwitch.isOn
        emailDescription2.isHidden = !emailSwitch.isOn
    }
    @IBAction func done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    @IBAction func acceptButton(_ sender: Any) {
        if(mandatoryGDPRSwitch.isOn){

            let parameters: Parameters = [
                "hash": patientHash,
                "accept_design_and_manufacture_soles": mandatoryGDPRSwitch.isOn,
                "accept_followed_of_his_treatment" : emailSwitch.isOn,
                "email_patient" : emailField.text!
            ]
            
            Alamofire.request(Utils.getApiAddress(key: Utils.API_GDPR_1) + patientHash + Utils.getApiAddress(key: Utils.API_GDPR_2) , method: .post, parameters: parameters).responseJSON { response in
                
                self.performSegue(withIdentifier: "gdprAccepted", sender: self)
            }
        }else{
            //Popup saying that first swith need to be accepted
            self.displayPopupMessage(message: NSLocalizedString("Pour continuer, veuillez accepter au minimum : ", comment: "") + NSLocalizedString("Pour la conception et la fabrication 3D de ses semelles", comment: ""), type: 1)
        }
    }
    @IBAction func refuseButton(_ sender: Any) {
        // popup saying are you sure ?
        // if yes, segue back to the qr code
        
        self.displayPopupMessage(message: NSLocalizedString("Êtes-vous certain de décliner ? Il ne sera dès lors pas possible d'utiliser le service 3D pour ce patient", comment: ""), type: 2)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is Foot3DScanViewController
        {
            let vc = segue.destination as? Foot3DScanViewController
            
            vc?.patientHash = self.patientHash
            vc?.token = self.token
            vc?.num_card = self.num_card
            vc?.onTheMoveScan = self.onTheMoveScan
        }
    }
    
    func displayPopupMessage(message:String, type: Int) {
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
}


extension GdprViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder() // dismiss keyboard
        return true
    }
}
