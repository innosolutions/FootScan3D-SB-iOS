//
//  PodoOnTheMove.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 16/05/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//
import DropDown
import UIKit
import Alamofire

class PodoOnTheMove: UIViewController {
    let dropDown = DropDown()
    @IBOutlet var NewPatient: UIView!
    @IBOutlet weak var dropdownGender: UITextField!
    @IBOutlet weak var createPatientButton: UIButton!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var dayDB: UITextField!
    @IBOutlet weak var monthBD: UITextField!
    @IBOutlet weak var yearBD: UITextField!
    var activeField: UITextField?
    var keyboardHeight: CGFloat!
    var lastOffset: CGPoint! = CGPoint.init(x: 0, y: 0)

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
   
    
    //    @IBOutlet weak var GenderChoiceTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        Utils.addGradientToView(view: self.view)
        dropDown.anchorView = dropdownGender
        dropDown.dataSource = [
            NSLocalizedString("Femme", comment: ""),
            NSLocalizedString("Homme", comment: ""),
            NSLocalizedString("Enfant", comment: ""),
            NSLocalizedString("Non listé", comment: "")
        ]
        dropDown.direction = .bottom
        dropdownGender.inputView = UIView()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.dropdownGender.text = item
        }
        
        createPatientButton.layer.cornerRadius = 15
        createPatientButton.layer.masksToBounds = true
        
        
        self.fieldSetup()
    
        self.setUpDoneButton()
       
    }
    
    @IBAction func showOptions(_ sender: Any) {
        dropDown.show()
        DispatchQueue.main.async {
            self.dropdownGender.endEditing(true)
        }
    }
    
    func birthdateCreator(day : String , month : String , year: String) -> Any{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-mm-yyyy" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        //according to date format your date string
        let date = dateFormatter.date(from: day + "-" +  month + "-" + year)
        return date ?? " "
        
    }
    
    @IBAction func createPatientFunction(_ sender: Any) {
        let birthdate = dayDB.text! + "-" + monthBD.text! + "-" + yearBD.text!
        let token = UserDefaults.standard.string(forKey: "token") ?? " "
        let headers: HTTPHeaders = [
            "x-Auth-Token": token
        ]
        
        let parameters: Parameters = [
            "firstname": self.lastname.text!,
            "email": self.email.text!,
            "gender":self.dropdownGender.text!,
            "birthdate": birthdate,
            "lastname" : self.surname.text!
        ]
        
        Alamofire.request(Utils.getApiAddress(key: Utils.API_CREATE_PATIENT),
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
            .responseSwiftyJSON{ response in
                
                Utils.notLoggedIn(response: response.value , viewController: self)
                
                if(response.response?.statusCode == 200){
                    let status =  response.value?["status"].string
                    if status == "success" {
                        let patientHashForSegue : String = response.value?["data"]["hash"].string ?? "NO HASH IN RESPONSE"
                        Utils.displayFullCustomisableAlert(message: NSLocalizedString("Votre patient à été créé avec succès", comment: ""),
                                title: NSLocalizedString("Success", comment: ""),
                                okActionText: "ok",
                                viewController: self,
                                buttonOkMethodHandler: { (self) in
                                    self.performSegue(withIdentifier: "GDPRPatientCreatedSegue", sender: patientHashForSegue)
                            
                        })
                    }else{
//                        print("ERROR")
                        let errorCode = response.response?.statusCode
                        let errorMessage = response.value?["message"].stringValue ?? NSLocalizedString("Erreur inconnue", comment: "")
                        Utils.displayErrorMessage(message: NSLocalizedString("L'erreur suivante est survenue : ", comment: "") + "\(errorCode ?? 000) - " + errorMessage, viewController: self)
                    }
                }else{
//                    print(response.value)
                    let errorCode = response.response?.statusCode
                    let errorMessage = response.value?["message"].stringValue ?? NSLocalizedString("Erreur inconnue", comment: "")
                    Utils.displayErrorMessage(message: NSLocalizedString("L'erreur suivante est survenue : ", comment: "") + "\(errorCode ?? 000) - " + errorMessage, viewController: self)
                }
                
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: UITextFieldDelegate
extension PodoOnTheMove: UITextFieldDelegate {
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
extension PodoOnTheMove {
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            
//             self.scrollView.isScrollEnabled = true
//             let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
//
//             self.scrollView.contentInset = contentInsets
//             self.scrollView.scrollIndicatorInsets = contentInsets
//
//             var aRect : CGRect = self.view.frame
//             aRect.size.height -= self.keyboardHeight
//            print("ACTIVE FIELD", self.activeField)
//
//             if let activeField = self.activeField {
//                 if (!aRect.contains(activeField.frame.origin)){
//                     self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
//                 }
//             }
            
            // move if keyboard hide input field
//            let offset: CGFloat = 200
//            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)! - offset
//            let collapseSpace = keyboardHeight - distanceToBottom
//            if collapseSpace < 0 {
//                // no collapse
//                return
//            }
            // set new offset for scroll view
            
            if let activeField = self.activeField {
                let activeFieldFrame = activeField.convert(activeField.frame, to: nil)
            
                let fieldDistFromBottom = self.scrollView.frame.size.height - activeFieldFrame.origin.y - activeFieldFrame.size.height
                print(keyboardHeight,fieldDistFromBottom)
                
                if (keyboardHeight > fieldDistFromBottom){
                    UIView.animate(withDuration: 0.3, animations: {
                        // scroll to the position above keyboard 10 points
                        self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardHeight)
                    })
                }
            }
            print("Keyboard height" ,keyboardHeight)

        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: 0)
        }
        
        keyboardHeight = nil
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GdprViewController
        {
            let patientHashForSegue = sender as? String
            let vc = segue.destination as? GdprViewController
            vc?.patientHash = patientHashForSegue ?? "NO HASH FOUND"
            vc?.token =  UserDefaults.standard.string(forKey: "token") ?? " "
            vc?.onTheMoveScan = true
        }
    }
    
    /* this add a "Done" button on top of the phoneTextField keyboard so that user can close the keyboard. */
    private func setUpDoneButton() {
        let toolbar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("OK", comment: ""), style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([space, doneButton], animated: false)
        toolbar.sizeToFit()
        self.dayDB.inputAccessoryView = toolbar
        self.monthBD.inputAccessoryView = toolbar
        self.yearBD.inputAccessoryView = toolbar
    }
    
    
    private func fieldSetup(){
        
      let lastNamePlaceholder = NSAttributedString(string: NSLocalizedString("Name" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
      let surnamnePlaceholder = NSAttributedString(string: NSLocalizedString("Firstname" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
      let emailPlaceholder = NSAttributedString(string: NSLocalizedString("Email" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
      let dayPlaceHolder = NSAttributedString(string: NSLocalizedString("Day" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
         
      let monthPlaceholder = NSAttributedString(string: NSLocalizedString("Month" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
      let yearPlaceholder = NSAttributedString(string: NSLocalizedString("year" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

      let genderPlaceholder = NSAttributedString(string: NSLocalizedString("Patient Gender" , comment : ""),attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
         
         
     self.surname.backgroundColor = .white
     self.surname.textColor = .darkGray
     self.surname.attributedPlaceholder = surnamnePlaceholder
     self.lastname.backgroundColor = .white
     self.lastname.textColor = .darkGray
     self.lastname.attributedPlaceholder = lastNamePlaceholder
     self.dropdownGender.backgroundColor = .white
     self.dropdownGender.attributedPlaceholder = genderPlaceholder
     self.dropdownGender.textColor = .darkGray
     self.dayDB.backgroundColor = .white
     self.dayDB.textColor = .darkGray
     self.dayDB.attributedPlaceholder = dayPlaceHolder
     self.monthBD.backgroundColor = .white
     self.monthBD.textColor = .darkGray
     self.monthBD.attributedPlaceholder = monthPlaceholder
     self.yearBD.backgroundColor = .white
     self.yearBD.textColor = .darkGray
     self.yearBD.attributedPlaceholder = yearPlaceholder
     self.email.backgroundColor = .white
     self.email.textColor = .darkGray
     self.email.attributedPlaceholder = emailPlaceholder

     self.dropdownGender.allowsEditingTextAttributes = false
     self.dayDB.keyboardType = UIKeyboardType.numberPad
     self.monthBD.keyboardType = UIKeyboardType.numberPad
     self.yearBD.keyboardType = UIKeyboardType.numberPad
     self.dayDB.autocorrectionType = .no
     self.monthBD.autocorrectionType = .no
     self.yearBD.autocorrectionType = .no
     // Observe keyboard change
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     
     self.yearBD.delegate = self
     self.monthBD.delegate = self
     self.dayDB.delegate = self
     
     self.surname.delegate = self
     self.lastname.delegate = self
     self.email.delegate = self
    
        
    }
    
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
}
