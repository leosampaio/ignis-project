//
//  Location.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 13/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Location {
    
    let key: String
    let name: String
    let lat: Float
    let lon: Float
    let ref: FIRDatabaseReference?
    
    init(name: String, lat: Float, lon: Float, key: String = "") {
        self.key = key
        self.name = name
        self.lat = lat
        self.lon = lon
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        lat = snapshotValue["lat"] as! Float
        lon = snapshotValue["lon"] as! Float
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "lat": lat,
            "lon": lon
        ]
    }
}
