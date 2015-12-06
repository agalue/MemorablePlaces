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

class EditPlaceViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var place: Place!
    var managedObjectContext: NSManagedObjectContext!
    var locationManager: CLLocationManager!
    var selectedPoint: MKPointAnnotation!
    
    @IBAction func save(sender: AnyObject) {
        // Warn the user if there are no selected point on the map
        if selectedPoint == nil {
            showAlertWithTitle("Warning", message: "Your place needs a coordinate. Long press on the map to select a place.", cancelButtonTitle: "OK")
            return
        }
        
        if let name = nameText.text {
            // Create Entity if necessary (add new places)
            if place == nil {
                // Create Entity
                let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: self.managedObjectContext)
                
                // Initialize Place
                place = Place(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
            }
            
            // Update Place
            place.name = name
            place.updateFromPointAnnotation(selectedPoint)
            
            do {
                // Save Place
                print("Saving place \(place.name)")
                try place.managedObjectContext?.save()
                
                // Dismiss View Controller
                navigationController?.popViewControllerAnimated(true)
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
        
        // Configure Fields
        nameText.delegate = self
        if place == nil {
            navigationItem.title = "Add Place"
        } else {
            navigationItem.title = "Edit Place"
        }

        // Configure long press gesture
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:") // The colon is for receiving the gesture recognizer object
        uilpgr.minimumPressDuration = 2
        mapView.addGestureRecognizer(uilpgr)
        
        // Initialize location Manager
        if place == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            // Update View
            nameText.text = place.name
            selectedPoint = place.getPointAnnotation()
            mapView.addAnnotation(selectedPoint)
            
            // Set Map Region
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(selectedPoint.coordinate, span)
            mapView.setRegion(region, animated: true)
        }
    }

    // Hide keyboard feature
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard feature
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Long press gesture handler
    func action(gestureRecognizer:UIGestureRecognizer) {
        // Be sure to react only on the first long press
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        // Grab map coordinates from touch point
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        // Remove previous selected point if any
        if (selectedPoint != nil) {
            mapView.removeAnnotation(selectedPoint)
        }
        
        // Update selected point
        selectedPoint = MKPointAnnotation()
        selectedPoint.coordinate = coordinate
        selectedPoint.title = "Unknown"
        mapView.addAnnotation(selectedPoint)
        
        // Retrieve the physical address
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let e = error {
                print("Reverse geocoder failed with error " + e.localizedDescription)
                return
            }
            if let placemark = placemarks?[0] {
                let addressFields = placemark.addressDictionary!["FormattedAddressLines"] as! [String]
                self.selectedPoint.title = addressFields.joinWithSeparator(", ")
            }
        })
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(userLocation.coordinate, span)
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
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
