//
//  PatientListTableViewController.swift
//  Gespodo FootScan 3D
//
//  Created by Bertrand Steenput on 27/05/2019.
//  Copyright © 2019 Gespodo. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftyJSON

class HeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var patientFirstName: UILabel!
    @IBOutlet weak var patientInitial: UILabel!

    
}

class PatientListTableViewController: UITableViewController, UISearchResultsUpdating {

    var patients : [Patient] = []
    @IBOutlet var patientList: UITableView!
    var resultSearchController = UISearchController()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resultSearchController = ({
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.searchBar.sizeToFit()
            searchController.searchBar.barTintColor = UIColor(named: "PrimaryBG")
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
//            tableView.tableHeaderView = controller.searchBar
            tableView.backgroundView?.backgroundColor = UIColor(named: "PrimaryBG")
            return searchController
        })()
        tableView.reloadData()
        searchPatient(query: "")
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! HeadlineTableViewCell
        
        let initial : String = "\(patients[indexPath.row].firstname.prefix(1))" + "\(patients[indexPath.row].lastname.prefix(1))"
        cell.patientFirstName?.text = patients[indexPath.row].firstname + " " + patients[indexPath.row].lastname
        cell.patientInitial?.text = initial
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Vos Patients", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patientForScan = Patient.init(lastname: patients[indexPath.row].lastname,
                                      firstname: patients[indexPath.row].firstname,
                                      date: patients[indexPath.row].date,
                                      gender: patients[indexPath.row].gender,
                                      email: patients[indexPath.row].email,
                                      hash: patients[indexPath.row].hash
        )
        self.resultSearchController.isActive = false
        self.performSegue(withIdentifier: "GDPRSegue", sender: patientForScan)
        
    }
    
    // MARK: - Retrieve Patient List
    func updateSearchResults(for searchController: UISearchController) {
        searchPatient(query : searchController.searchBar.text!)
    }
    func searchPatient(query : String){
//        let scheme: String = "https://"
//        let host : String = "api.gespodo.com"
//
//        var url : String = Utils.apiBaseAddress
//        var url : String = scheme + host
//        url.append("/api/users/patients/")
        
        var url : String = Utils.getApiAddress(key: Utils.API_PATIENT_LIST)
        let queryParameters = "?length=1000&order[0][columns]=0&columns[0][data]=id&order[0][dir]=desc&search[value]=" + query + "&start=0"
        url.append(queryParameters)
        
        let headers: HTTPHeaders = [
            "x-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? " "
        ]
        
        Alamofire.request(url, method: .get , headers: headers).responseSwiftyJSON{
            DataResponse in
            self.patients.removeAll()
//            print("DEBUG A.1", DataResponse.value)
            Utils.notLoggedIn(response: DataResponse.value, viewController: self)
            
            
            if let json = DataResponse.value?["datas"] {
                
                for (_,currentPatient):(String, JSON) in json {
                    let thispatient = Patient.init(
                        lastname: currentPatient["lastname"].stringValue,
                        firstname: currentPatient["firstname"].stringValue,
                        date: "",
                        gender: currentPatient["gender"].stringValue,
                        email: currentPatient["email"].stringValue,
                        hash: currentPatient["hash"].stringValue)
                    self.patients.append(thispatient)
                }
            }
            self.patientList.reloadData()
        }
    }
    
   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GdprViewController
        {
            let patientForSegue = sender as? Patient
            let vc = segue.destination as? GdprViewController
            vc?.patientHash = patientForSegue?.hash ?? "NO HASH FOUND"
            vc?.token =  UserDefaults.standard.string(forKey: "token") ?? " "
            vc?.onTheMoveScan = true
        }
    }
}
