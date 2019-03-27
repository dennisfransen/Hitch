//
//  MapVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class MapVC: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters : Double = 5000
    let db = Firestore.firestore()
    var region = MKCoordinateRegion()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()

        
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        // Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print("ERROR")
            } else {
                // Remove annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                // Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                // Save data to trip collection in database
                guard let currentUser = Auth.auth().currentUser else { return }
                let userID = currentUser.uid
            
                // Save current and target location and timestamp
                let currentLocation = GeoPoint(latitude: self.region.center.latitude, longitude: self.region.center.longitude)
                let targetLocation = GeoPoint(latitude: latitude!, longitude: longitude!)
                var expireDate = Date()
                expireDate.addTimeInterval(24 * 3600)
                
                let currentLocationData : [String: Any] = ["currentLocation": currentLocation]
                let targetAndCurrentLocationData : [String: Any] = ["expireDate": expireDate, "currentLocation": currentLocation, "targetLocation": targetLocation]
                self.db.collection("trip").document(userID).setData(targetAndCurrentLocationData)
                self.db.collection("users").document(userID).updateData(currentLocationData)
                
                self.notifyNearbyUsers()
                
                // Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                // Zooming in on annotation
                let cooridinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let regionAnnotation = MKCoordinateRegion(center: cooridinate, latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
                self.mapView.setRegion(regionAnnotation, animated: true)
                
            }
        }
    }
    

    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            self.region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Visa en alert om användaren inte tillåter "Visa min position"
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            
            print("ALERT!")
            
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("something")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // SCHOULD BE ON A GOD DAMN SERVER!
    func notifyNearbyUsers() {
        
        let db = Firestore.firestore()
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        db.collection("users").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let myLocation = GeoPoint(latitude: self.region.center.latitude, longitude: self.region.center.longitude)
                for document in querySnapshot!.documents {
                    
                    if (document.documentID == userID) {
                        continue
                    }
                    
                    if let coords = document.get("currentLocation") {
                        let otherLocation = coords as! GeoPoint
                        
                        if self.distance(location1: myLocation, location2: otherLocation) < 3000 {
                            print("HÄMTA MIG")
                            
                            // Push notis till användare som är i närheten!
                        }
                    } else {
                        print("Wehepp")
                        
                        // Tyvärr det fanns ingen i närheten!
                        // TODO: Sätt upp en pop-up meny här.
                    }
                }
            }
        }
        
    }
    
    func distance(location1: GeoPoint, location2: GeoPoint) -> Double {
        
        let coordinate1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let coordinate2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        
        return distanceInMeters
        //        return sqrt(pow((location1.latitude - location2.latitude), 2) + pow((location1.longitude - location2.longitude), 2))
    }
    
    
    
    
    
}

extension MapVC : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let regionL = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(regionL, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    
}
