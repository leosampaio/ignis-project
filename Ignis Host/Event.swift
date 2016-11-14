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
    var presents: [String: AnyObject]?
    let templateID: String
    let startTime: String
    let ref: FIRDatabaseReference?
    
    init(name: String, templateID: String, startTime: String, key: String = "") {
        self.key = key
        self.templateID = templateID
        self.startTime = startTime
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        templateID = snapshotValue["templateID"] as! String
        presents = snapshotValue["presents"] as? [String: AnyObject]
        startTime = snapshotValue["startTime"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "templateID": templateID,
            "startTime": startTime
        ]
    }
}
