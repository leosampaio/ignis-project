//
//  EventAddViewController.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 14/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class EventAddViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationPickerView: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    var locations:[Location] = []
    
    let ref = FIRDatabase.database().reference(withPath: "event-templates")
    let locationRef = FIRDatabase.database().reference(withPath: "locations")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationPickerView.delegate = self
        self.nameTextField.delegate = self
        
        locationRef.observe(.value, with: { snapshot in
            
            var newLocations: [Location] = []
            
            for location in snapshot.children {
                let location = Location(snapshot: location as! FIRDataSnapshot)
                newLocations.append(location)
            }
            
            self.locations = newLocations
            self.locationPickerView.reloadAllComponents()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressSave(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        let selectedLocationRow = self.locationPickerView.selectedRow(inComponent: 0)
        let locationID = self.locations[selectedLocationRow].key
        
        let newEventTemplate = EventTemplate(name: name, locationID: locationID, hostID: "host")
        let newEventTemplateRef = self.ref.childByAutoId()
        
        newEventTemplateRef.setValue(newEventTemplate.toAnyObject()) { (error, ref) -> Void in
            self.saveButton.showLoading(show: false)
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.saveButton.showLoading(show: true)
    }
    
    // - MARK: UIPickerView delegate and data source
    
    // The number of columns of data
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard self.locations.count != 0 else { return 1 }
        return self.locations.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard self.locations.count != 0 else { return "No locations created yet" }
        return self.locations[row].name
    }

    // - MARK UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            nameTextField.resignFirstResponder()
        }
        return true
    }
}
