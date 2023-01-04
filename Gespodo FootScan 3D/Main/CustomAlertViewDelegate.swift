//
//  CustomAlertViewDelegate.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 08/03/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit

protocol CustomAlertViewDelegate: class {
    func okButtonTapped(selectedOption: String, textFieldValue: String)
    func cancelButtonTapped()
}
