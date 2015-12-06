//
//  EditPlaceViewController.swift
//  MemorablePlaces
//
//  Created by Alejandro Galue on 12/6/15.
//  Copyright © 2015 Street Dog Studio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class EditPlaceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    var record: NSManagedObject!
    var locationManager = CLLocationManager()
    var selectedPoint: MKPointAnnotation!
    
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func save(sender: AnyObject) {
        let name = nameText.text
        
        // Warn the user if there are no selected point on the map
        if selectedPoint == nil {
            showAlertWithTitle("Warning", message: "Your place needs a coordinate. Long press on the map to select a place.", cancelButtonTitle: "OK")
            return
        }
        
        if let isEmpty = name?.isEmpty where isEmpty == false {
            // Populate Record
            record.setValue(name, forKey: "name")
            record.setValue(selectedPoint.coordinate.latitude, forKey: "latitude")
            record.setValue(selectedPoint.coordinate.longitude, forKey: "longitude")
            record.setValue(selectedPoint.subtitle, forKey: "address")
            
            do {
                // Save Record
                try record.managedObjectContext?.save()
                
                // Dismiss View Controller
                dismissViewControllerAnimated(true, completion: nil)
            } catch {
                let saveError = error as NSError
                print("\(saveError), \(saveError.userInfo)")
                
                // Show error to the user
                showAlertWithTitle("Warning", message: "Your place could not be saved.", cancelButtonTitle: "OK")
            }
        } else {
            // Warn the user if there is no name for the place.
            showAlertWithTitle("Warning", message: "Your place needs a name.", cancelButtonTitle: "OK")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize location Manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Configure long press gesture
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:") // The colon is for receiving the gesture recognizer object
        uilpgr.minimumPressDuration = 2
        mapView.addGestureRecognizer(uilpgr)

        // Get the information from the current place
        let name = record.valueForKey("name") as! String
        let latitude = record.valueForKey("latitude") as! Double
        let longitude = record.valueForKey("longitude") as! Double
        let address = record.valueForKey("address") as! String
        
        // Add the current place on the map
        selectedPoint = MKPointAnnotation()
        selectedPoint.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        selectedPoint.title = name
        selectedPoint.subtitle = address
        mapView.addAnnotation(selectedPoint)
        
        // Update label
        nameText.text = name
    }

    private func showAlertWithTitle(title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: nil))
        
        // Present Alert Controller
        presentViewController(alertController, animated: true, completion: nil)
    }

}
