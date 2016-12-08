//
//  Event.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 13/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

struct Event {
    
    let key: String
    var participants: [String: AnyObject]?
    let templateID: String
    // TODO: turn this automatically into NSDate
    let startTime: String
    let beaconMajor: Int
    let beaconMinor: Int
    let ref: FIRDatabaseReference?
    
    init(templateID: String, startTime: String, beaconMajor: Int = 1, beaconMinor: Int = 1, key: String = "") {
        self.key = key
        self.templateID = templateID
        self.startTime = startTime
        self.participants = [:]
        self.beaconMajor = beaconMajor
        self.beaconMinor = beaconMinor
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        templateID = snapshotValue["templateID"] as! String
        participants = snapshotValue["participants"] as? [String: AnyObject]
        startTime = snapshotValue["startTime"] as! String
        beaconMajor = snapshotValue["beaconMajor"] as! Int
        beaconMinor = snapshotValue["beaconMinor"] as! Int
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "templateID": templateID,
            "startTime": startTime,
            "participants": participants ?? [:],
            "beaconMajor": beaconMajor,
            "beaconMinor": beaconMinor
        ]
    }
}
