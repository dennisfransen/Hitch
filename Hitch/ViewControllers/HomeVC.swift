//
//  HomeVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import UserNotifications

class HomeVC: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var availableButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if granted {
                print("Notifications is allowed")
            } else {
                print("Notifications is not allowed!")
            }
        }
  
    }
    
    @IBAction func sidemenuButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "homeToSidemenu", sender: self)
    }
    
    @IBAction func thumbGesturePressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "homeToMap", sender: self)
    }
    
    @IBAction func availableButtonPressed(_ sender: UIButton) {
        let locationManager = appDelegate.locationManager
        
        availableButton.isSelected = !availableButton.isSelected
        availableButton.setTitle(availableButton.isSelected ? "In my car" : "At home", for: .normal)
        if availableButton.isSelected == true {
            availableButton.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        } else {
            availableButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            locationManager.stopUpdatingLocation()
            self.appDelegate.arrayOfNearbyUsers.removeAll()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let meDriving2D: CLLocationCoordinate2D = manager.location!.coordinate
        let meDrivingCL = CLLocation(latitude: meDriving2D.latitude, longitude: meDriving2D.longitude)
        let meDrivingGP = GeoPoint(latitude: meDrivingCL.coordinate.latitude, longitude: meDrivingCL.coordinate.longitude)
        
        var previousCarLocationGP = GeoPoint(latitude: appDelegate.carLocation.coordinate.latitude, longitude: appDelegate.carLocation.coordinate.longitude)

        if previousCarLocationGP.latitude < 0.5 && previousCarLocationGP.longitude < 0.5 {
            let carLocationCL = CLLocation(latitude: meDrivingGP.latitude, longitude: meDrivingGP.longitude)
            appDelegate.carLocation = carLocationCL
            previousCarLocationGP = GeoPoint(latitude: appDelegate.carLocation.coordinate.latitude, longitude: appDelegate.carLocation.coordinate.longitude)
        }
        
        let dist = DistCalculator.distance(location1: meDrivingGP, location2: previousCarLocationGP)
        
        if DistCalculator.distance(location1: meDrivingGP, location2: previousCarLocationGP) > 2.0 {
            let carLocationCL = CLLocation(latitude: meDrivingGP.latitude, longitude: meDrivingGP.longitude)
            appDelegate.carLocation = carLocationCL
            checkAllTripLocationsFromDatabase(currentLocation: meDrivingGP)
            print("DU HAR GÅTT LÄNGE!")
        }
        
        print("locations = \(meDriving2D.latitude) \(meDriving2D.longitude) Distans: \(dist)")
        print("GP 1: \(meDrivingGP.latitude) \(meDrivingGP.longitude)")
        print("GP 2: \(previousCarLocationGP.latitude) \(previousCarLocationGP.longitude)")
    }
    
    func checkAllTripLocationsFromDatabase(currentLocation: GeoPoint) {
        
        let db = Firestore.firestore()
        var arrayOfNearbyUsers = [QueryDocumentSnapshot]()
        var arrayChanged = false

        if appDelegate.processing {
            return
        }
        
        db.collection("trip").getDocuments { (querySnapshots, error) in
            
            if let error = error {
                print("Error gettings documents: \(error)")
            } else {
                print("Hello")
                for document in querySnapshots!.documents {
                    if DistCalculator.distance(location1: document.get("currentLocation") as! GeoPoint , location2: currentLocation) < 3000 {
                        arrayOfNearbyUsers.append(document)
                    }
                }
                
                if arrayOfNearbyUsers.count == self.appDelegate.arrayOfNearbyUsers.count {
                    for i in 0...arrayOfNearbyUsers.count - 1 {
                        if arrayOfNearbyUsers[i].documentID != self.appDelegate.arrayOfNearbyUsers[i].documentID {
                            arrayChanged = true
                            break
                        }
                    }
                } else {
                    arrayChanged = true
                }
                
                if arrayChanged {
                    self.appDelegate.arrayOfNearbyUsers = arrayOfNearbyUsers
                    self.notifyUser()
                }
                
            }
            
        }
        
    }
    
    func notifyUser() {
        
        let db = Firestore.firestore()
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "Hitch Hiker"
        
        let trigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        for i in 0...appDelegate.arrayOfNearbyUsers.count - 1 {
            
            let userId = appDelegate.arrayOfNearbyUsers[i].documentID
            
            let docRef = db.collection("users").document(userId)
            docRef.getDocument { (DocumentSnapshot, error) in
                if let _ = error {
                    print("Error")
                } else {
                    let firstName = DocumentSnapshot!.get("firstName") as! String
                    let lastName = DocumentSnapshot!.get("lastName") as! String
                    content.body = "\(firstName) \(lastName) is nearby"
                    let request: UNNotificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                    //TODO: Lägg till location i content.subtitle = "location" från databas omvandlat till adress.
                }
                
            }
            
        }
        
    }
    
}
