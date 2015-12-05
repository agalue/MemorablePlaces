//
//  ViewController.swift
//  MemorablePlaces
//
//  Created by Alejandro Galue on 12/1/15.
//  Copyright © 2015 Street Dog Studio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AddPlaceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    var managedObjectContext: NSManagedObjectContext!
    var locationManager = CLLocationManager()
    var selectedPoint: MKPointAnnotation!

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        let name = nameText.text
        
        if selectedPoint == nil {
            // Show Alert View
            showAlertWithTitle("Warning", message: "Your place needs a coordinate. Long press on the map to select a place.", cancelButtonTitle: "OK")
            return
        }
        
        if let isEmpty = name?.isEmpty where isEmpty == false {
            // Create Entity
            let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: self.managedObjectContext)
            
            // Initialize Record
            let record = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
            
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
                
                // Show Alert View
                showAlertWithTitle("Warning", message: "Your place could not be saved.", cancelButtonTitle: "OK")
            }
        } else {
            // Show Alert View
            showAlertWithTitle("Warning", message: "Your place needs a name.", cancelButtonTitle: "OK")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:") // The colon is for receiving the gesture recognizer object
        uilpgr.minimumPressDuration = 2
        mapView.addGestureRecognizer(uilpgr)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func action(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        if (selectedPoint != nil) {
            mapView.removeAnnotation(selectedPoint)
        }
        selectedPoint = MKPointAnnotation()
        selectedPoint.coordinate = coordinate
        selectedPoint.title = "Your Place!"
        selectedPoint.subtitle = "Calculating address..."
        mapView.addAnnotation(selectedPoint)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let e = error {
                print("Reverse geocoder failed with error " + e.localizedDescription)
                return
            }
            if let placemark = placemarks?[0] {
                let addressFields = placemark.addressDictionary!["FormattedAddressLines"] as! [String]
                self.selectedPoint.subtitle = addressFields.joinWithSeparator(", ")
            }
        })
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

