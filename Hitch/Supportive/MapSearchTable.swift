//
//  MapSearchTable.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-27.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapSearchTable: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil
    let db = Firestore.firestore()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

extension MapSearchTable {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        
        return cell
    }
    
    func parseAddress(selectedItem : MKPlacemark) -> String {
        // Put a space between "4" and "Melrose place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // Put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.administrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // Put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format: "%@%@%@%@%@%@%@",
            // Street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // Street name
            selectedItem.thoroughfare ?? "",
            comma,
            // City
            selectedItem.locality ?? "",
            secondSpace,
            // State
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}

extension MapSearchTable: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView else { return }
        guard let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension MapSearchTable {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row].placemark
        
        // Save data to trip collection in database
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        let currentLocation = GeoPoint(latitude: appDelegate.myLocation!.coordinate.latitude, longitude: appDelegate.myLocation!.coordinate.longitude)
        let targetLocation = GeoPoint(latitude: selectedItem.coordinate.latitude, longitude: selectedItem.coordinate.latitude)
        
        var expireDate = Date()
        expireDate.addTimeInterval(24 * 3600)
        
        let currentLocationData : [String: Any] = ["currentLocation": currentLocation]
        let targetAndCurrentLocationData : [String: Any] = ["expireDate": expireDate, "currentLocation": currentLocation, "targetLocation": targetLocation]
        self.db.collection("users").document(userID).updateData(currentLocationData)
        self.db.collection("trip").document(userID).setData(targetAndCurrentLocationData)
        
        
        notifyNearbyUsers()
        
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
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
                let myLocation = GeoPoint(latitude: (self.appDelegate.myLocation?.coordinate.latitude)!, longitude: (self.appDelegate.myLocation?.coordinate.longitude)!)
                for document in querySnapshot!.documents {
                    
                    if (document.documentID == userID) {
                        continue
                    }
                    
                    if let coords = document.get("currentLocation") {
                        let otherLocation = coords as! GeoPoint
                        
                        if DistCalculator.distance(location1: myLocation, location2: otherLocation) < 3000 {
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
    
}
