//
//  HostingViewController.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 13/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SetupHostingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var startHostingButton: UIView!
    @IBOutlet weak var eventTemplatePickerView: UIPickerView!
    
    let eventTempRef = FIRDatabase.database().reference(withPath: "event-templates")
    
    var eventTemplates:[EventTemplate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startHostingButton.layer.cornerRadius = self.startHostingButton.frame.width/2
        
        self.eventTemplatePickerView.dataSource = self
        self.eventTemplatePickerView.delegate = self
        
        eventTempRef.observe(.value, with: { snapshot in

            var newEventTemplates: [EventTemplate] = []
            
            for eventTemplate in snapshot.children {
                let eventTemplate = EventTemplate(snapshot: eventTemplate as! FIRDataSnapshot)
                newEventTemplates.append(eventTemplate)
            }

            self.eventTemplates = newEventTemplates
            self.eventTemplatePickerView.reloadAllComponents()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // - MARK UIPickerView delegate and data source
    
    // The number of columns of data
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard self.eventTemplates.count != 0 else { return 1 }
        return self.eventTemplates.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard self.eventTemplates.count != 0 else { return "No events created yet" }
        return self.eventTemplates[row].name
    }
    
    // MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let row = self.eventTemplatePickerView.selectedRow(inComponent: 0)
        
        let hostingVC = segue.destination as! HostingViewController
        hostingVC.eventTemplate = self.eventTemplates[row]
    }
}

