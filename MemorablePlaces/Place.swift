//
//  Place.swift
//  MemorablePlaces
//
//  Created by Alejandro Galue on 12/6/15.
//  Copyright © 2015 Street Dog Studio. All rights reserved.
//

import Foundation
import MapKit
import CoreData

@objc(Place)
class Place: NSManagedObject {
    
    @NSManaged var name:String
    @NSManaged var address:String
    @NSManaged var latitude:Double
    @NSManaged var longitude:Double

    internal func getPointAnnotation() -> MKPointAnnotation {
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        point.title = self.name
        point.subtitle = self.address
        return point
    }
    
    internal func updateFromPointAnnotation(pointAnnotation: MKPointAnnotation) {
        self.name = pointAnnotation.title!
        self.latitude = pointAnnotation.coordinate.latitude
        self.longitude = pointAnnotation.coordinate.longitude
        self.address = pointAnnotation.subtitle!
    }
    
}