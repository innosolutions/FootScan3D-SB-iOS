//
//  EndScanViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 04/02/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit

class EndScanViewController: UIViewController {
    
    var num_hash : String = ""
    var onTheMove : Bool = false
    
    @IBOutlet weak var newScanButton: UIButton!
    @IBOutlet weak var goPro: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.addGradientToView(view: self.view)
      
        newScanButton.layer.cornerRadius = 15
        newScanButton.layer.masksToBounds = true
        newScanButton.layer.borderWidth = 1
        newScanButton.layer.borderColor = UIColor(named: "colorPrimaryDark")!.cgColor
        goPro.layer.cornerRadius = 15
        goPro.layer.masksToBounds = true
        goPro.layer.borderWidth = 1
        goPro.setTitle(NSLocalizedString("go-pro", comment: ""), for: .normal)
        
    }
    @IBAction func openGespodoOnline(_ sender: Any) {
        if(onTheMove){
            let url : String = Utils.getApiAddress(key: Utils.GO_TO_WEB_NEWCARD)
            let urlComponents = URLComponents (string: url)!
            UIApplication.shared.open (urlComponents.url!)
        }else{
            let url : String = Utils.getApiAddress(key: Utils.GO_TO_WEB_PRO) + num_hash
            let urlComponents = URLComponents (string: url)!
            UIApplication.shared.open (urlComponents.url!)
        }
    } 
}
