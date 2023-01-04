//
//  SubscriptionViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 24/01/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import DropDown
import PhoneNumberKit
import FlagPhoneNumber
import Alamofire

class SubscriptionViewController: UIViewController {
    let dropDown = DropDown()
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var country: String = ""
    var phoneNumber:String = ""
    var sucess: Bool = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var phoneNumberTextField: FPNTextField!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var acceptCondition: UISwitch!
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldForJobs: UITextField!
    
    @IBOutlet var jobsDropdown: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.addGradientToView(view: self.view)
        name.delegate = self
        firstname.delegate = self
        email.delegate = self
        textFieldForJobs.delegate = self
        phoneTextField.delegate = self
        dropDown.anchorView = textFieldForJobs // UIView or UIBarButtonItem
        subscribeButton.layer.cornerRadius = 15
        subscribeButton.layer.masksToBounds = true
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = [
            
            NSLocalizedString("Podiatrist / DPM", comment: ""),
            NSLocalizedString("Podiatrist Student", comment: ""),
            NSLocalizedString("Orthotics prosthetics Specialist", comment: "") ,
            NSLocalizedString("Pharmacist", comment: ""),
            NSLocalizedString("Physician, Physio, Osteo ", comment: ""),
            NSLocalizedString("Medical Device shop", comment: ""),
            NSLocalizedString("Hospital", comment: ""),
            NSLocalizedString("Nursing Home", comment: "") ,
            NSLocalizedString("Footwear professionals", comment: ""),
            NSLocalizedString("Patient", comment: ""),
            NSLocalizedString("Other", comment: "")
           
        ]
        dropDown.direction = .bottom
        textFieldForJobs.inputView = UIView()
        
        self.fieldSetup()
        
        self.hideKeyboardWhenTappedAround()
        self.setUpDoneButton()
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textFieldForJobs.text = item
        }
        
        title = "FlagPhoneNumber"
        
        // To use your own flag icons, uncommment the line :
        //        Bundle.FlagIcons = Bundle(for: ViewController.self)
        phoneNumberTextField = FPNTextField(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 16, height: 50))
        phoneNumberTextField.borderStyle = .roundedRect
        
        // Comment this line to not have access to the country list
//        phoneNumberTextField.parentViewController = self
        phoneNumberTextField.delegate = self
        
        // Custom the size/edgeInsets of the flag button
        phoneNumberTextField.flagButtonSize = CGSize(width: 35, height: 35)
//        phoneNumberTextField.flagButtonEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        phoneNumberTextField.hasPhoneNumberExample = true
        phoneNumberTextField.setCountries(including: [.FR, .ES, .IT, .BE, .LU, .DE])
        // Exclude countries from the list
        //        phoneNumberTextField.setCountries(excluding: [.AM, .BW, .BA])
        // Set the flag image with a region code
        //        phoneNumberTextField.setFlag(for: "FR")
        // Set the phone number directly
        //        phoneNumberTextField.set(phoneNumber: "+33612345678")
//        view.addSubview(phoneNumberTextField)
        
        phoneNumberTextField.center = view.center
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tmpStr = NSLocalizedString("general_condition"  , comment: "Accepter les conditions d'utilisation")
        let attributedString = NSMutableAttributedString(string: tmpStr )
        let url = URL(string: NSLocalizedString("https://www.gespodo.com/fr/conditions-dutilisation-confidentialite", comment: ""))!
        
        // Shitty behavior, manipulating strings by index bason on translated string is risky. Crash when tmpStr length is <13...
        // Set the 'click here' substring to be the link
        attributedString.setAttributes([.link: url], range: NSMakeRange(13, tmpStr.count - 13))
        
        self.conditionOfUse.attributedText = attributedString
        self.conditionOfUse.isUserInteractionEnabled = true
        self.conditionOfUse.isEditable = false
        
        // Set how links should appear: blue and underlined
        self.conditionOfUse.textColor = UIColor.white
        self.conditionOfUse.textAlignment = NSTextAlignment.right
        self.conditionOfUse.font = UIFont.boldSystemFont(ofSize: 14.0)
        self.conditionOfUse.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
    }
    
    @IBOutlet weak var conditionOfUse: UITextView!
    @IBAction func buttonShowDropDown(_ sender: Any) {
        dropDown.show()
        DispatchQueue.main.async {
            self.textFieldForJobs.endEditing(true)
        }
    }
    
    /* this add a "Done" button on top of the phoneTextField keyboard so that user can close the keyboard. */
    private func setUpDoneButton() {
        let toolbar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("OK", comment: ""), style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([space, doneButton], animated: false)
        toolbar.sizeToFit()
        self.phoneTextField.inputAccessoryView = toolbar
    }
    
    private func fieldSetup(){
        let namePlaceholder = NSAttributedString(string: NSLocalizedString("Name" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let firstnamePlaceholder = NSAttributedString(string: NSLocalizedString("Firstname" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        let emailPlaceholder = NSAttributedString(string: NSLocalizedString("Email" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let jobsPlaceholder = NSAttributedString(string: NSLocalizedString("Fonction" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let phonePlaceholder = NSAttributedString(string: phoneNumberTextField.placeholder ?? "",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.name.attributedPlaceholder = namePlaceholder
        self.firstname.attributedPlaceholder = firstnamePlaceholder
        self.email.attributedPlaceholder = emailPlaceholder
        self.textFieldForJobs.attributedPlaceholder = jobsPlaceholder
        self.phoneNumberTextField.attributedPlaceholder = phonePlaceholder
        
        
        
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @IBAction func registerDemo(_ sender: Any) {
        
        let parameters: Parameters = [
            "firstname" : self.firstname.text ?? "" ,
            "lastname" : self.name.text ?? "" ,
            "email" : self.email.text ?? "" ,
            "phone" : self.phoneNumber ,
            "job" : self.textFieldForJobs.text ?? "",
            "country" : self.country,
            "accept_condition" : Int(truncating: NSNumber(value: self.acceptCondition.isOn))
            
        ]
        
        Alamofire.request(Utils.getApiAddress(key: Utils.API_NEW_DEMO_USER), method: .post, parameters: parameters).responseJSON { response in
                print(response)
            
            let tmp1 : NSDictionary = response.result.value as! NSDictionary
            let result: Int = (tmp1.value(forKey: "result") as? Int ?? 0)
            
            if result == 1 {
                    // Go to QR code scan
                    self.sucess = true
                    self.performSegue(withIdentifier: "subscribtionSucceeded", sender: self)
                
                } else{
                    let tmp : NSDictionary = response.result.value as! NSDictionary
                let errorMsg =  tmp.value(forKey: "message") as? String ?? NSLocalizedString("Pas de message d'erreur", comment: "")
                self.displayErrorMessage(message : NSLocalizedString("Veuillez compléter tous les champs d'inscription et/ou indiquer une adresse email valable. Message d'erreur : ", comment: "") + errorMsg)
                }
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
//        print("SUCCEED", self.sucess)
//        if self.sucess
//        {
//            print("SUCCEED two", self.sucess)
//            let vc = segue.destination as? LoginViewController
//
//            vc?.subrsciptionSucceeded = self.sucess
//        }
        
        
        if segue.identifier == "subscribtionSucceeded" && self.sucess  {

             if let navController = segue.destination as? UINavigationController {

                 if let childVC = navController.topViewController as? LoginViewController {
                      //TODO: access here chid VC  like childVC.yourTableViewArray = localArrayValue
                     
                     childVC.subscriptionSucceeded = self.sucess


                 }

             }

         }
    }
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: NSLocalizedString("Erreur:", comment: ""), message: message, preferredStyle: .alert)
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



extension SubscriptionViewController: FPNTextFieldDelegate {
    func fpnDisplayCountryList(){
        
    }
    

    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
        if(isValid){
            self.phoneNumber =  textField.getFormattedPhoneNumber(format: .E164) ?? ""
        }
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
        self.country = name
    }
}

// MARK: UITextFieldDelegate
extension SubscriptionViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

// MARK: Keyboard Handling
extension SubscriptionViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
                
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height + 80
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            let offset: CGFloat = 20
            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)! - offset
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
            
            self.scrollView.contentOffset = self.lastOffset
        }
        
        keyboardHeight = nil
    }
}


