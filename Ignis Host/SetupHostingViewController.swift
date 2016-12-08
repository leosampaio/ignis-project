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
import CoreLocation

class SetupHostingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var startHostingButton: UIView!
    @IBOutlet weak var eventTemplatePickerView: UIPickerView!
    @IBOutlet weak var startHostingButtonLbel: UIButton!
    @IBOutlet weak var lookingForBeaconLabel: UILabel!
    
    let eventTempRef = FIRDatabase.database().reference(withPath: "event-templates")
    
    var eventTemplates:[EventTemplate] = []
    
    // beacon related properties
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon?
    var lastProximity: CLProximity = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // beacon lookup setup
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = UUID(uuidString: "699ebc80-e1f3-11e3-9a0f-0cf3ee3bc012")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.ignisapp")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startUpdatingLocation()
        
        // show loading until a beacon is found
        self.startHostingButtonLbel.showLoading(show:true)
        self.lookingForBeaconLabel.isHidden = false
        
        // Firebase setup
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
    
    // MARK - location manager delegate methods
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.startHostingButtonLbel.showLoading(show:false)
        self.lookingForBeaconLabel.isHidden = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        lastFoundBeacon = nil // kill the beacon, we are far from it
        self.startHostingButtonLbel.showLoading(show:true)
        self.lookingForBeaconLabel.isHidden = false
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        }
        else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // check if we have any beacon
        guard beacons.count > 0 else {
            lastFoundBeacon = nil
            
            return
        }
        self.startHostingButtonLbel.showLoading(show:false)
        self.lookingForBeaconLabel.isHidden = true
        
        let closestBeacon = beacons[0]
        
        // check if it's not the same as the last one
        guard closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity else {return}
        lastFoundBeacon = closestBeacon
        lastProximity = closestBeacon.proximity
        
        if let lastFoundBeacon = lastFoundBeacon,
            lastFoundBeacon.proximity == .unknown {
            self.startHostingButtonLbel.showLoading(show:true)
            self.lookingForBeaconLabel.isHidden = false
        }
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
    
    // MARK - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard lastFoundBeacon != nil else {return false}
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let beacon = lastFoundBeacon else {return}
        let row = self.eventTemplatePickerView.selectedRow(inComponent: 0)
        
        let hostingVC = segue.destination as! HostingViewController
        hostingVC.eventTemplate = self.eventTemplates[row]
        hostingVC.beacon = beacon
    }
    
    
}

