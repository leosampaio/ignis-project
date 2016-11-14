//
//  LocationAddViewController.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 14/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class LocationAddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
    let ref = FIRDatabase.database().reference(withPath: "locations")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
        self.latTextField.delegate = self
        self.lonTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressSave(_ sender: Any) {
        guard let name = nameTextField.text,
            let latString = latTextField.text,
            let lat = Float(latString),
            let lonString = lonTextField.text,
            let lon = Float(lonString) else { return }
        
        let newLocation = Location(name: name, lat: lat, lon: lon)
        let newLocationRef = self.ref.childByAutoId()
        
        newLocationRef.setValue(newLocation.toAnyObject()) { (error, ref) -> Void in
            self.saveButton.showLoading(show: false)
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.saveButton.showLoading(show: true)
    }
    
    // - MARK UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.latTextField.becomeFirstResponder()
        }
        if textField == self.nameTextField {
            self.lonTextField.becomeFirstResponder()
        }
        if textField == lonTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
