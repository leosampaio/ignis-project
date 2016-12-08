//
//  FirstViewController.swift
//  Ignis
//
//  Created by Leonardo Sampaio on 13/10/16.
//  Copyright © 2016 ignis. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import Firebase
import FirebaseDatabase

class SingleViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lblBeaconReport: UILabel!
    @IBOutlet weak var lblBeaconDetails: UILabel!
    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var participateView: UIView!
    @IBOutlet weak var participateButton: UIButton!
    
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon?
    var lastProximity: CLProximity = .unknown
    
    let eventTemplateRef = FIRDatabase.database().reference(withPath: "event-templates")
    let eventRef = FIRDatabase.database().reference(withPath: "events")
    let locationRef = FIRDatabase.database().reference(withPath: "locations")
    
    var event:Event?
    var participantRef:FIRDatabaseReference?
    var email:String?
    var isParticipating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblBeaconDetails.isHidden = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = UUID(uuidString: "699ebc80-e1f3-11e3-9a0f-0cf3ee3bc012")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.ignisapp")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startUpdatingLocation()
        
        lblBeaconReport.text = "Spotting beacons..."
        disableParticipation()
    
        self.participateView.layer.cornerRadius = self.participateView.frame.width/2
        
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if let user = user {
                self.email = user.email
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressParticipate(_ sender: Any) {
        if let event = self.event,
            let email = self.email {
            if !isParticipating {
                self.participantRef = event.ref?.child("participants").childByAutoId()
                if let participantRef = self.participantRef {
                    participantRef.setValue(email) { (error, ref) -> Void in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        } else {
                            self.participateButton.setTitle("Leave", for: .normal)
                            self.isParticipating = true
                        }
                    }
                }
            } else {
                if let participantRef = self.participantRef {
                    participantRef.removeValue()
                    self.isParticipating = false
                }
            }
        }
    }
    
    // MARK: location manager delegate methods
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        }
        else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.isHidden = false
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.isHidden = true
        disableParticipation()
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        var shouldHideBeaconDetails = true
        
        if beacons.count > 0 {
            let closestBeacon = beacons[0]
            if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                lastFoundBeacon = closestBeacon
                lastProximity = closestBeacon.proximity
                
                var proximityMessage: String!
                if let lastFoundBeacon = lastFoundBeacon {
                    switch lastFoundBeacon.proximity {
                    case .immediate:
                        proximityMessage = "Very close"
                        
                    case .near:
                        proximityMessage = "Near"
                        
                    case .far:
                        proximityMessage = "Far"
                        
                    default:
                        proximityMessage = "Where's the beacon?"
                        disableParticipation()
                    }
                    
                    shouldHideBeaconDetails = false
                    
                    lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.intValue) + "\nMinor = " + String(closestBeacon.minor.intValue) + "\nDistance: " + proximityMessage
                    
                    
                    if lastFoundBeacon.proximity != .unknown {
                        // lookup if there is such event
                        eventRef.queryOrderedByKey().queryLimited(toLast: 10)
                            .observeSingleEvent(of: .value, with: {
                            (snapshot) in
                                guard snapshot.exists() else {
                                    self.lblLocation.text = "Unknown Location"
                                    self.lblEvent.text = "No Event Nearby"
                                    return
                                }
                                for event in snapshot.children.reversed() {
                                    let event = Event(snapshot: event as! FIRDataSnapshot)
                                    if event.beaconMinor == closestBeacon.minor.intValue
                                        && event.beaconMajor == closestBeacon.major.intValue {
                                        self.setEventTemplate(event: event)
                                        return
                                    }
                                }
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        lblBeaconDetails.isHidden = shouldHideBeaconDetails
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error)
    }

    func setEventTemplate(event: Event) {
        eventTemplateRef.child(event.templateID).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard snapshot.exists() else {
                self.lblEvent.text = "Unkown Event"
                return
            }
            let eventTemplate = EventTemplate(snapshot: snapshot)
            guard eventTemplate.isBeingHosted else {
                self.disableParticipation()
                return
            }
            self.lblEvent.text = eventTemplate.name
            self.setLocation(eventTemplate: eventTemplate)
            self.event = event
            self.participateButton.isEnabled = true
            self.participateButton.showLoading(show: false)
            if (!self.isParticipating) {
                self.participateButton.setTitle("Participate!", for: .normal)
            } else {
                self.participateButton.setTitle("Leave", for: .normal)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setLocation(eventTemplate: EventTemplate) {
        locationRef.child(eventTemplate.locationID).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard snapshot.exists() else {
                self.lblLocation.text = "Unkown Location"
                return
            }
            let location = Location(snapshot: snapshot)
            self.lblLocation.text = location.name
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func disableParticipation() {
        self.lblLocation.text = "Unknow"
        self.lblEvent.text = "No Event Nearby"
        self.participateButton.isEnabled = false
        self.participateButton.showLoading(show: true)
        self.participateButton.setTitle("", for: .normal)
    }
}
