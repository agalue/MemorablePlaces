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
            
            // Add a point on the map for each place
            for place in places as! [NSManagedObject] {
                let name = place.valueForKey("name") as! String
                let latitude = place.valueForKey("latitude") as! Double
                let longitude = place.valueForKey("longitude") as! Double
                let address = place.valueForKey("address") as! String
                
                let point = MKPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                point.title = name
                point.subtitle = address
                mapView.addAnnotation(point)
            }
        } catch {
            print("\(error)")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let viewController = segue.destinationViewController as? TableViewController { // TODO I'm not sure why
            viewController.managedObjectContext = self.managedObjectContext
        }
    }

}
