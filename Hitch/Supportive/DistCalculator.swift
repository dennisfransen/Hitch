//
//  DistCalculator.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-27.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import Firebase
import MapKit

class DistCalculator {
    
    static func distance(location1: GeoPoint, location2: GeoPoint) -> Double {
        
        let coordinate1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let coordinate2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        
        return distanceInMeters
    }
    
}
