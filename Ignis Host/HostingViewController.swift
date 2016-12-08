//
//  HostingViewController.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 14/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import CoreLocation

class HostingViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var participantsCountView: UIView!
    @IBOutlet weak var participantsCountLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var participantsTableView: UITableView!
    
    let eventTempRef = FIRDatabase.database().reference(withPath: "event-templates")
    let locationRef = FIRDatabase.database().reference(withPath: "locations")
    let eventRef = FIRDatabase.database().reference(withPath: "events")
    let userRef = FIRDatabase.database().reference(withPath: "users")
    var thisEventRef:FIRDatabaseReference? = nil
    
    var eventTemplate:EventTemplate!
    var location:Location?
    var event:Event?
    var participants:[String] = []
    
    let dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
    
    var beacon: CLBeacon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.participantsTableView.dataSource = self
        
        // set event nam and get info on the event's location
        self.eventNameLabel.text = self.eventTemplate.name
        locationRef.child(self.eventTemplate.locationID).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard snapshot.exists() else {
                self.locationNameLabel.text = "Unkown Location"
                return
            }
            self.location = Location(snapshot: snapshot)
            self.locationNameLabel.text = self.location?.name
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.startEvent()
        
        // make the counter's border rounded
        self.participantsCountView.layer.cornerRadius = self.participantsCountView.frame.width/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Event Handling methods
    
    private func startEvent() {
        
        // create event
        let formatter = DateFormatter()
        formatter.dateFormat = self.dateFormat
        let stringDate: String = formatter.string(from: Date())
        self.event = Event(templateID: self.eventTemplate.key,
                           startTime: stringDate,
                           beaconMajor: beacon?.major.intValue ?? 0,
                           beaconMinor: beacon?.minor.intValue ?? 0)
        
        // add to firebase
        self.thisEventRef = self.eventRef.childByAutoId()
        self.thisEventRef?.setValue(self.event?.toAnyObject()) { (error, ref) -> Void in
            if let error = error {
                print(error.localizedDescription)
                _ = self.navigationController?.popViewController(animated: true)
                return
            }
            self.observeUsers()
        }

        self.eventTemplate.ref?.child("isBeingHosted").setValue(true)
    }
    
    private func stopEvent() {
        
    }
    
    private func observeUsers() {
        // check and update participants list
        self.thisEventRef?.child("participants").observe(.childAdded, with: { snap in

            guard let email = snap.value as? String else { return }
            self.participants.append(email)
            let row = self.participants.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            self.participantsTableView.insertRows(at: [indexPath], with: .top)
            
            self.participantsCountLabel.text = self.participants.count.description
        })
        
        self.thisEventRef?.child("participants").observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else { return }
            for (index, email) in self.participants.enumerated() {
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.participants.remove(at: index)
                    self.participantsTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
            self.participantsCountLabel.text = self.participants.count.description
        })
    }
    
    // MARK: - Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParentViewController {
            self.eventTemplate.ref?.child("isBeingHosted").setValue(false)
        }
    }
    
    // MARK: - Table View delegate and data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath)
        let participant = self.participants[indexPath.row]
        cell.textLabel?.text = participant
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participants.count
    }
}
