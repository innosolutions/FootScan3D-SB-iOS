import UIKit
import MessageUI

class CustomAlertView: UIViewController , MFMailComposeViewControllerDelegate {
   
    
    
    @IBOutlet weak var titleLabel: UILabel!
   
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var conditionOfUseButton: UIButton!
    @IBOutlet weak var makeAWishButton: UIButton!
    @IBOutlet weak var bugs: UIButton!
    @IBOutlet weak var gdpr: UIButton!
    @IBOutlet weak var privacy: UIButton!
    @IBOutlet weak var supportText: UITextView!
    
    var delegate: CustomAlertViewDelegate?
    var selectedOption = "First"
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        supportText.text = NSLocalizedString("Cliquez sur le lien correspondant à votre requête:", comment: "")
        gdpr.setTitle(NSLocalizedString("Conditions Générales d’utilisation", comment: ""),for: .normal)
        
        makeAWishButton.makeItLookLikeALink()
        bugs.makeItLookLikeALink()
        conditionOfUseButton.makeItLookLikeALink()
        gdpr.makeItLookLikeALink()
        privacy.makeItLookLikeALink()
    }
    @IBAction func noticeOfUse(_ sender: Any) {
        let urlComponents = URLComponents(string: "https://www.gespodo.com/fr/Footscan3D_instruction")!
        UIApplication.shared.open (urlComponents.url!)
    }
    @IBAction func makeAWish(_ sender: Any) {
        sendEmail(email: "makeawish@gespodo.com", objectOfTheEmail: NSLocalizedString("Souhait d'amélioration de l'app (iOS)", comment: "") , defaultMessage: "" )
    }
    @IBAction func sendBug(_ sender: Any) {
        sendEmail(email : "bug@gespodo.com", objectOfTheEmail: NSLocalizedString("Bug sur l'application Android FootScan 3D", comment: "") , defaultMessage: NSLocalizedString("Decrivez votre problème avec un maximum de détails afin de permettre au support de mieux vous aider", comment: "") )
    }
    
    func sendEmail(email : String , objectOfTheEmail : String , defaultMessage : String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody(defaultMessage, isHTML: true)
            mail.setSubject(objectOfTheEmail)
            
            present(mail, animated: true)
        } else {
            let appURL = URL(string: "mailto:" + email)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL as URL)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func gdprButton(_ sender: Any) {
        let urlComponents = URLComponents(string: NSLocalizedString("https://www.gespodo.com/fr/CGU_FOOTSCAN3D", comment: ""))!
        UIApplication.shared.open (urlComponents.url!)
        
    }
    @IBAction func privacyButton(_ sender: Any){
        let urlComponents = URLComponents(string: NSLocalizedString("https://www.gespodo.com/fr/data-privacy", comment: ""))!
        UIApplication.shared.open (urlComponents.url!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UIButton {
    func makeItLookLikeALink() {
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value : UIColor.blue , range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
