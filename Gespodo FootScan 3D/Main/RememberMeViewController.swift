//
//  RememberMeViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 15/02/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//
import Alamofire
import UIKit
/*
    This controller is provinding the view that is used when the user is already connected.
    If the user is not connected. He is redirected to the login page.
 */
class RememberMeViewController: UIViewController {
    @IBOutlet weak var scanWithQRCode: UIButton!
    @IBOutlet weak var changeUserButton: UIButton!
    @IBOutlet weak var versionName: UITextView!
    @IBOutlet weak var textForLogin: UITextView!
    @IBOutlet weak var onTheMoveScan: UIButton!
    
    let str = NSLocalizedString("Vous allez vous connecter en tant que: ", comment: "")
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let defaults: UserDefaults? = UserDefaults.standard
        textForLogin.text = str
        if defaults?.string(forKey: "login") != nil {
            textForLogin.text = textForLogin.text + (defaults?.value(forKey: "login") as! String)
        }else{
            clearUserAndGoToLogin()
        }
        if defaults?.string(forKey: "isDemo") != nil {
            let isDemo : Bool = (defaults?.value(forKey: "isDemo") as! Bool)
            Utils.setDemo(demo: isDemo)
        }else{
            Utils.setDemo(demo: true)
        }
        
        scanWithQRCode.layer.cornerRadius = 15
        scanWithQRCode.layer.masksToBounds = true
        changeUserButton.layer.cornerRadius = 15
        changeUserButton.layer.masksToBounds = true
        onTheMoveScan.layer.cornerRadius = 15
        onTheMoveScan.layer.masksToBounds = true
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        versionName.text = NSLocalizedString("Version : ", comment: "") + version
        let userToken = UserDefaults.standard.string(forKey: "userHash") ?? " "
        let headers: HTTPHeaders = [
            "x-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? " "
        ]
        
        if(Utils.getDemo()){
            onTheMoveScan.isHidden = true
            scanWithQRCode.setTitle(NSLocalizedString("Démarrer un scan", comment: ""), for: UIControl.State.normal)
        }else{
            print("USER HASH", userToken)
            print("HEADER", headers)
            Alamofire.request(Utils.getApiAddress(key: Utils.CHECK_TOKEN_VALIDIDTY_API) + userToken, method: .get, headers: headers).responseSwiftyJSON{ response in
                Utils.notLoggedIn(response: response.value , viewController: self)
            }
        }
    }
    
    @IBAction func segueToNextPage(_ sender: Any) {
        if(Utils.getDemo()){
            // Enter DEMO mode
            self.performSegue(withIdentifier: "goToFootScanFromRember", sender: self)
        }else{
            self.performSegue(withIdentifier: "goToQRCodeScannerFromRember", sender: self)
        }
        
    }
    
    /*
      This function is used to the segue to login page and to remove the user informations
     */
    func clearUserAndGoToLogin(){
        UserDefaults.standard.removeObject(forKey: "ISRemember")
        UserDefaults.standard.set(false ,forKey: "ISRemember")
        Utils.setDemo(demo: false)
        self.performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    @IBAction func clearUserAndGoToLoginButton(_ sender: Any) {
        //segue to Login and clear user data
        clearUserAndGoToLogin()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is Foot3DScanViewController && Utils.getDemo()
        {
            let defaults: UserDefaults? = UserDefaults.standard
            let vc = segue.destination as? Foot3DScanViewController
            let demoHash : String = (defaults?.value(forKey: "userHash") as! String)
            vc?.demoHash = demoHash
        }
    }
}
