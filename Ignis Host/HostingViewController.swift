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

class HostingViewController: UIViewController {

    @IBOutlet weak var participantsCountView: UIView!
    @IBOutlet weak var participantsCountLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var participantsTableView: UITableView!
    
    let eventTempRef = FIRDatabase.database().reference(withPath: "event-templates")
    let locationRef = FIRDatabase.database().reference(withPath: "locations")
    
    var eventTemplate:EventTemplate!
    var location:Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.participantsCountView.layer.cornerRadius = self.participantsCountView.frame.width/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
