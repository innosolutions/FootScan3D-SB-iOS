//
//  Patient.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 27/05/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import Foundation
// MARK : Properties

class Patient {
    
    var lastname : String
    var firstname: String
    var date : String
    var gender : String
    var email : String
    var hash : String
    
    init(lastname : String , firstname: String , date:String , gender:String, email:String , hash: String) {
        self.lastname = lastname
        self.firstname = firstname
        self.date = date
        self.gender = gender
        self.email = email
        self.hash = hash
    }
}
