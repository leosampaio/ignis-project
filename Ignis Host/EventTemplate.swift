//
//  EventTemplate.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 13/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

struct EventTemplate {
    
    let key: String
    let name: String
    let locationID: String
    let hostID: String
    let ref: FIRDatabaseReference?
    
    init(name: String, locationID: String, hostID: String, key: String = "") {
        self.key = key
        self.name = name
        self.locationID = locationID
        self.hostID = hostID
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        locationID = snapshotValue["locationID"] as! String
        hostID = snapshotValue["hostID"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "locationID": locationID,
            "hostID": hostID
        ]
    }
}
