//
//  ViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 15/01/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import Firebase
import Alamofire_SwiftyJSON
import SwiftyJSON
class LoginViewController: UIViewController {
    
    @IBOutlet weak var login_Text: UITextField!
    @IBOutlet weak var password_text: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var signIn_button: UIButton!
    @IBOutlet weak var rememberMe: UISwitch!
    @IBOutlet weak var versionName: UITextView!
    @IBOutlet weak var rememberMeText: UITextView!
    

    static var demoUser : Bool = false
    var demoHash: String = ""
    var subscriptionSucceeded: Bool = false
    var login : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rememberMeText.text = NSLocalizedString("Se souvenir de moi", comment: "")
        Utils.addGradientToView(view: self.view)
        login_Text?.layer.cornerRadius = 15
        login_Text?.layer.masksToBounds = true
//        login_Text?.placeholder = NSLocalizedString("Identifiant ou code à 6 chiffres" , comment : "")
        
        let loginPlaceholder = NSAttributedString(string: NSLocalizedString("Identifiant ou code à 6 chiffres" , comment : ""),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        login_Text?.attributedPlaceholder = loginPlaceholder
        password_text?.layer.cornerRadius = 15
        password_text?.layer.masksToBounds = true
//        password_text?.placeholder = NSLocalizedString("Mot de passe" , comment : "")
        
        
        let passPlaceholder = NSAttributedString(string: NSLocalizedString("Mot de passe" , comment : ""),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        password_text?.attributedPlaceholder = passPlaceholder
        
        login_button?.layer.cornerRadius = 15
        login_button?.layer.masksToBounds = true
        
        
        signIn_button?.layer.cornerRadius = 15
        signIn_button?.layer.masksToBounds = true
        signIn_button?.layer.borderWidth = 1
        signIn_button?.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        
        self.hideKeyboardWhenTappedAround()
        
        rememberMe?.addTarget(self, action: #selector(self.stateChanged), for: .valueChanged)
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        versionName?.text = NSLocalizedString("Version : " , comment : "")  + version
        
    }
    
    
    @objc func stateChanged(_ switchState: UISwitch) {
        let defaults: UserDefaults? = UserDefaults.standard
        if switchState.isOn {
            defaults?.set(true, forKey: "ISRemember")
        }
        else {
            defaults?.set(false, forKey: "ISRemember")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(subscriptionSucceeded){
            print("HELLLLLLLO")
            self.displaySuceedMessage(message: NSLocalizedString("Votre compte démo Gespodo à bien été créé, veuillez consulter vos emails afin d'obtenir vos accès", comment : ""))
        }
        let defaults: UserDefaults? = UserDefaults.standard
        
        // check if defaults already saved the details
        if defaults?.bool(forKey: "ISRemember") ?? false {
            self.performSegue(withIdentifier: "rememberMeOn", sender: self )
        }else {
            rememberMe.setOn(false, animated: false)
        }
    }
    
    @IBAction func login_button(_ sender: UIButton) {        
        if(Utils.getDemo()){
            UserDefaults.standard.set(self.login_Text.text , forKey: "login")
            UserDefaults.standard.set(self.demoHash, forKey: "userHash")
            UserDefaults.standard.set(Utils.getDemo(), forKey: "isDemo")
            Analytics.logEvent("loging_ios", parameters: [
                "demo": 1,
                "demoHash" : self.demoHash
                ])
            self.performSegue(withIdentifier: "startScannerDemo", sender: self)
        }else{

            let login: String = (login_Text.text)!
            let password: String = password_text.text ?? ""
            
            // The se connecter button should send a request to the webdigit server
            let parameters: Parameters = [
                "login": login,
                "password": password
            ]
        
            Alamofire.request(Utils.getApiAddress(key: Utils.API_LOGIN), method: .post, parameters: parameters).responseSwiftyJSON { response in
                if response.response?.statusCode == 403 {
                    self.displayErrorMessage(message : NSLocalizedString("Votre identifiant ou votre mot de passe est incorrect. Veuillez réessayer avec des identifiants correctes", comment : "" ))
                }else if response.response?.statusCode == 200{
                    UserDefaults.standard.set(self.login_Text.text , forKey: "login")
                    
                    UserDefaults.standard.set(false, forKey: "isDemo")

                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        let token = Utils.decodeJson(code: utf8Text, keys: ["token"])
                        print("TOKEN",token)
                        UserDefaults.standard.set(token[0], forKey: "token")
                        let userhash = response.result.value?["user"]["hash"]
                        UserDefaults.standard.set(userhash?.stringValue ?? "NO HASH FOUND" , forKey: "userHash")
                        
                    }
                    
                    Analytics.logEvent("loging_ios", parameters: [
                        "demo": 0,
                        "login" : self.login_Text.text!
                        ])
                    self.performSegue(withIdentifier: "loginSucessSegue", sender: self)
                }
            }
        }
    }
    
    func displaySuceedMessage(message:String) {
        let alertView = UIAlertController(title: NSLocalizedString("Félicitation!", comment : "" ), message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: NSLocalizedString("Erreur!", comment : "" ), message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    @IBAction func onTypeLOgin(_ sender: Any) {
        print(">>>>>" , self.login_Text.text ?? "")
        if(self.login_Text.text?.count == 6) {
            checkIfDemoUser(demoLogin: self.login_Text.text ?? "");
        }else{
            setDemoFlag(isDemo: false);
        }
    }
    
    func checkIfDemoUser(demoLogin : String){
        let login: String = (login_Text.text)!
        // The se connecter button should send a request to the webdigit server
        let parameters: Parameters = [
            "code": login,
        ]
        
        Alamofire.request(Utils.getApiAddress(key: Utils.API_DEMO_LOGIN), method: .post, parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 202 {
                //Not a demo user
                self.setDemoFlag(isDemo: false)
            }else if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                // This is a demo user
                self.setDemoFlag(isDemo: true)
                
                let json: NSDictionary = response.result.value as! NSDictionary
                let tmp : NSDictionary = json.value(forKey: "user") as! NSDictionary
                    self.demoHash = tmp.value(forKey: "hash") as! String
            }else{
                print("ERROR")
                print(response)
            }
        }
    }
    
    func getUserInfoFromRespone(userInfo : String) -> String {
        let user : [String] = Utils.decodeJson(code: userInfo , keys: ["user"])
        let result = Utils.decodeJson(code: user[0], keys: ["hash"])
        return result[0]
    }
    func setDemoFlag(isDemo : Bool){
        Utils.setDemo(demo: isDemo)
        if(isDemo){
            self.password_text.isEnabled = false
            self.view.endEditing(true)
            self.password_text.backgroundColor = UIColor.darkGray
        
        }else{
            self.password_text.isEnabled = true
            self.password_text.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func conditionOfUse(_ sender: Any) {
        let urlComponents = URLComponents (string: NSLocalizedString("https://www.gespodo.com/fr/conditions-dutilisation-confidentialite", comment: ""))!
        UIApplication.shared.open (urlComponents.url!)
        
    }
    
    
    @IBAction func done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is Foot3DScanViewController && Utils.getDemo()
        {
            let vc = segue.destination as? Foot3DScanViewController
            print(demoHash)
            vc?.demoHash = self.demoHash
        }
    }
}
// Put this piece of code anywhere you like
extension UIViewController {
   
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

