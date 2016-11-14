//
//  EventsTableViewController.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 13/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class EventsTableViewController: UITableViewController {

    let ref = FIRDatabase.database().reference(withPath: "event-templates")
    
    var eventTemplates: [EventTemplate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
        ref.observe(.value, with: { snapshot in
            
            var newEventTemplates: [EventTemplate] = []
            
            for eventTemplate in snapshot.children {
                let eventTemplate = EventTemplate(snapshot: eventTemplate as! FIRDataSnapshot)
                newEventTemplates.append(eventTemplate)
            }
            
            self.eventTemplates = newEventTemplates
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventTemplates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        let eventTemplate = self.eventTemplates[indexPath.row]
        
        cell.textLabel?.text = eventTemplate.name
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eventTemplate = self.eventTemplates[indexPath.row]
            eventTemplate.ref?.removeValue()
        }
    }
}
