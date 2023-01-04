//
//  ChoosePodoOnTheMoveViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 29/05/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit

class ChoosePodoOnTheMoveViewController: UIViewController {

    @IBOutlet weak var createMyPatient: UIButton!
    @IBOutlet weak var listPatientButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMyPatient.layer.cornerRadius = 15
        createMyPatient.layer.masksToBounds = true
        listPatientButton.layer.cornerRadius = 15
        listPatientButton.layer.masksToBounds = true
    }
}
