//
//  User.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 15/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import Foundation

import Firebase
import FirebaseAuth

struct User {

    let key: String
    let uid: String
    let email: String
    let ref: FIRDatabaseReference?
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
        key = ""
        ref = nil
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
        key = ""
        ref = nil
    }
    
}
