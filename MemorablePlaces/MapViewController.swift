//
//  MapViewController.swift
//  MemorablePlaces
//
//  Created by Alejandro Galue on 12/6/15.
//  Copyright © 2015 Street Dog Studio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest(entityName: "Place")
        request.returnsObjectsAsFaults = false
        do {
            // Get all places
            let places = try managedObjectContext.executeFetchRequest(request)

            var rect: MKMapRect = MKMapRectNull

            // Add a point on the map for each place
            for place in places as! [Place] {
                let annotation = place.getPointAnnotation()
                mapView.addAnnotation(annotation)
                // Update region boundaries
                let point: MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
                rect = MKMapRectUnion(rect, MKMapRectMake(point.x, point.y, 0, 0))
            }
                        
            // Set map region
            if !places.isEmpty {
                var region = MKCoordinateRegionForMapRect(rect)
                region.span.longitudeDelta *= 2; // Margin
                region.span.latitudeDelta *= 2; // Margin
                mapView.setRegion(mapView.regionThatFits(region), animated: true)
            }
        } catch {
            print("\(error)")
        }
    }    

}
