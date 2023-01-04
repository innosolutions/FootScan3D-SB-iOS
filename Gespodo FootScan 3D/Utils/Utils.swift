//
//  Utils.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 15/01/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Foundation
import Alamofire_SwiftyJSON
import SwiftyJSON
class Utils: NSObject{
    // List easily get the api route used by the phone
    class  var API_GDPR_1 : Int{
      return 1
    }
    class  var API_GDPR_2 : Int{
        return 2
    }
    class  var API_DEMO_LOGIN  : Int{
        return 3
    }
    class  var API_LOGIN  : Int{
        return 4
    }
    class  var API_FORGOT_PASSWORD  : Int{
        return 5
    }
    class  var API_NEW_DEMO_USER  : Int{
        return 6
    }
    class  var API_URL_UPLOAD_STL  : Int{
        return 7
    }  //"http://10.3.36.54:8080";
    class  var API_URL_UPLOAD_STL_PRO_PART_1  : Int{
        return 8
    }
    class  var API_URL_UPLOAD_STL_PRO_PART_2  : Int{
        return 9
    }
    class  var ASTRIVIS_DOWNLOAD_URL  : Int{
        return 10
    }
    class var ASTRIVIS_DOWNLOAD_FILE_URL : Int{
        return 11
    }
    class var CALL_TO_ACTION : Int{
        return 12
    }
    class var API_UPLOAD_WAITING_LIST_PART_1 : Int {
        return 13
    }
    class var API_UPLOAD_WAITING_LIST_PART_2 : Int {
        return 14
    }
    class var API_CREATE_PATIENT: Int {
        return 15
    }
    class var CHECK_TOKEN_VALIDIDTY_API: Int {
        return 16
    }
    class var GO_TO_WEB_PRO: Int {
        return 18
    }
    class var GO_TO_WEB_NEWCARD: Int {
        return 19
    }
    class var API_PATIENT_LIST: Int {
        return 20
    }
    static var DEMO_USER : Bool = false
    
    class func getDemo() -> Bool {
        return DEMO_USER
    }
    
    class func setDemo(demo : Bool){
        DEMO_USER = demo
    }
   
    // Change the display to adda a gradient to the view
   class func addGradientToView(view: UIView)
    {
        //gradient layer
        let gradientLayer = CAGradientLayer()
        let color: UIColor = UIColor(named: "colorPrimaryDark" )!
        
        //define colors
        gradientLayer.colors = [UIColor(named: "PrimaryBG")!.cgColor as Any, color.cgColor]
        
        //define locations of colors as NSNumbers in range from 0.0 to 1.0
        //if locations not provided the colors will spread evenly
        gradientLayer.locations = [0.4, 0.8]
        
        //define frame
        gradientLayer.frame = view.bounds
        
        //insert the gradient layer to the view layer
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Function that return a string with the correct path to the route, depending on
    // if the app is in debug mode or not
    class func getApiAddress(key : Int) -> String
    {
        let DEBUG = false
        let apiBaseAddress: String
        let apiDemoUserBaseAddress : String
        let baseCallToAction : String
        // TODO : make the debug constant dependant on the app environement
        if (DEBUG){
            baseCallToAction = "https://staging.angular.gespodo.com"
            apiBaseAddress = "https://staging.api.gespodo.com/api"
            apiDemoUserBaseAddress = "https://staging.api.gespodo.com/demo"
        }else{
            baseCallToAction = "https://labo.gespodo.com"
            apiBaseAddress = "https://api.gespodo.com/api"
            apiDemoUserBaseAddress = "https://api.gespodo.com/demo"
        }
        
        switch key{
        case API_GDPR_1:
            return apiBaseAddress + "/patient"
        case API_GDPR_2:
            return "/accept_gdpr"
        case API_DEMO_LOGIN:
            return apiDemoUserBaseAddress + "/users/login"
        case API_LOGIN:
            return apiBaseAddress + "/external/user/login"
        case API_FORGOT_PASSWORD:
            return apiBaseAddress + "/external/user/losing/password"
        case API_NEW_DEMO_USER:
            return apiDemoUserBaseAddress + "/users/subscribe"
        case API_URL_UPLOAD_STL_PRO_PART_1:
            return  apiBaseAddress + "/cards/"
        case API_URL_UPLOAD_STL_PRO_PART_2:
            return  "/file/upload"
        case ASTRIVIS_DOWNLOAD_URL:
            return "https://cloud.astrivis.com/gespodo/api/users/models"
        case ASTRIVIS_DOWNLOAD_FILE_URL:
            return "https://cloud.astrivis.com/gespodo/api/data"
        case CALL_TO_ACTION:
            return "https://pipedrivewebforms.com/form/7ba89b639d0ecce7068890e1acea04935828414"
        case API_UPLOAD_WAITING_LIST_PART_1:
            return apiBaseAddress + "/users/waitinglist/"
        case API_UPLOAD_WAITING_LIST_PART_2:
            return "/file/upload"
        case API_CREATE_PATIENT:
            return apiBaseAddress + "/patients/add/"
        case CHECK_TOKEN_VALIDIDTY_API:
            return apiBaseAddress + "/external/user/checktoken/"
        case GO_TO_WEB_PRO:
            return baseCallToAction + "/users/cards/card/"
        case GO_TO_WEB_NEWCARD:
            return baseCallToAction + "/users/cards/add"
        case API_PATIENT_LIST:
            return apiBaseAddress + "/users/patients/"
        default:
            return "";
        }
    }
    
    class func decodeJson(code : String , keys : [String]) -> [String] {
        var result: [String] = []
        
        do{
            let json = code.data(using: String.Encoding.utf8)!
            if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                
                for key in keys {
                    result.append(jsonData[key] as? String ?? "" )
                }
            }
        }
        catch{
            return []
        }
        return result
    }
    
    
    class func decodeQrCode(code: String) -> [String] {
        var result: [String] = []
        
        do{
            let json = code.data(using: String.Encoding.utf8)!
            if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                print("QR CODE", jsonData)
                let token = jsonData["token"] as? String ?? ""
                let hash = jsonData["hash_card"] as? String ?? ""
                let num = jsonData["num_card"] as? Int ?? nil
                
                
                if token.isEmpty && hash.isEmpty && num == nil {
                    result = []
                }else{
                    let num_card = "\(String(describing: num!))"
                    result = [token,hash,num_card]
                    
                }
                
                
                
                
                
            }
        }
        catch{
           return []
        }
     return result
    }
    
    class func notLoggedIn(response: JSON? , viewController: UIViewController){
        if let error = response?["message"].string {
            if error == "Invalid credentials."{
                displayFullCustomisableAlert(message: NSLocalizedString("Votre token d'authentification n'est plus valide, vous aller être redirigé sur la page de login", comment: ""),
                                             title: NSLocalizedString("Attention", comment: ""),
                                             okActionText: NSLocalizedString("ok", comment: ""),
                                             viewController: viewController) { (viewController) in
                            UserDefaults.standard.set(false, forKey: "ISRemember")
                            viewController.performSegue(withIdentifier: "goToLogin", sender: self )
                }
                
            }
        }
    }
    
    class  func displayErrorMessage(message:String, viewController : UIViewController) {
        let alertView = UIAlertController(title: NSLocalizedString("Erreur!", comment: ""), message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = viewController.view
            presenter.sourceRect = viewController.view.bounds
        }
        viewController.present(alertView, animated: true, completion:nil)
    }
    
    typealias MethodHandler1 = (_ samplerParameter: String) -> Void
    typealias MethodHandler2 = (_ viewControllerParameter: UIViewController) -> Void
    
    class  func displayFullCustomisableAlert(message:String,
                                      title: String,
                                      okActionText: String,
                                      viewController : UIViewController,
                                      buttonOkMethodHandler: @escaping MethodHandler2) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert )
        let OKAction = UIAlertAction(title: okActionText, style: .default) { (action:UIAlertAction) in
            buttonOkMethodHandler(viewController)
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = viewController.view
            presenter.sourceRect = viewController.view.bounds
        }
        viewController.present(alertView, animated: true, completion:nil)
    }
    

}
