//
//  DemoEndScanViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 08/02/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Firebase
class DemoEndScanViewController: UIViewController {
    var demoHash: String  = ""
    @IBOutlet weak var newScan: UIButton!
    @IBOutlet weak var callToAction: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.addGradientToView(view: self.view)
        // Do any additional setup after loading the view.
        
        newScan.layer.cornerRadius = 15
        newScan.layer.masksToBounds = true
        newScan.layer.borderWidth = 1
        newScan.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        
        callToAction.layer.cornerRadius = 15
        callToAction.layer.masksToBounds = true
        callToAction.layer.borderWidth = 1
        callToAction.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        callToAction.titleLabel?.numberOfLines = 3
    }
    
    @IBAction func callToAction(_ sender: Any) {
        let url : String = Utils.getApiAddress(key: Utils.CALL_TO_ACTION)// + "?id=" + demoHash
        let urlComponents = URLComponents (string: url)!
        Analytics.logEvent("click_to_fill_perso_info", parameters: [
            "demo": 1,
            "demoHash" : demoHash
            ])
        UIApplication.shared.open (urlComponents.url!)
    }
    
    
    @IBAction func moreInfo(_ sender: Any) {
        Analytics.logEvent("click_on_more_info", parameters: [
            "demo": 1,
            "demoHash" : demoHash
            ])
        let urlComponents = URLComponents (string: "https://www.gespodo.com/")!
        UIApplication.shared.open (urlComponents.url!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is Foot3DScanViewController
        {
            let vc = segue.destination as? Foot3DScanViewController
                vc?.demoHash = self.demoHash
                print("FootScan: ", demoHash)
                Analytics.logEvent("demo_new_scan", parameters: [
                "demo": 1,
                "demoHash" : demoHash
                ])
        }
        
    }
}
