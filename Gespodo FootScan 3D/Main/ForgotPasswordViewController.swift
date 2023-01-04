//
//  ForgotPasswordViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 15/01/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var sendNewMDP: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordForgotText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordForgotText.text = NSLocalizedString("Si vouz avez oublié votre mot de passe, indiquez-nous votre email afin que nous puissions vous en envoyer un nouveau.", comment: "")
        Utils.addGradientToView(view: self.view)
        sendNewMDP.layer.cornerRadius = 15
        sendNewMDP.layer.masksToBounds = true        // Do any additional setup after loading the view.
        
        
        
        let emailPlaceholder = NSAttributedString(string: NSLocalizedString("Email" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.emailTextField.attributedPlaceholder = emailPlaceholder
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let parameters : Parameters = [
            "email": self.emailTextField.text!
        ]
        Alamofire.request(Utils.getApiAddress(key: Utils.API_FORGOT_PASSWORD), method: .post, parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 200 {
                self.displaySucceedMessage(message: NSLocalizedString("Votre mot de passe à été réinitialisé avec succès, veuillez consulter vos emails pour obtenir vos nouveau accès", comment: ""))
            }else{
                self.displayErrorMessage(message: NSLocalizedString("Erreur lors de la réinitalisation de votre mot de passe", comment: ""))
                print(response.result)
            }
        }
    }
    
    
    func displaySucceedMessage(message:String) {
        let alertView = UIAlertController(title: NSLocalizedString("Réinitialisation Mot de Passe", comment: ""), message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: NSLocalizedString("Erreur", comment: ""), message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
}
