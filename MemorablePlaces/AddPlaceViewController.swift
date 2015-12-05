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

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        let name = nameText.text
        
        if let isEmpty = name?.isEmpty where isEmpty == false {
            // Create Entity
            print(self.managedObjectContext)
            let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: self.managedObjectContext)
            print(entity)
            
            // Initialize Record
            let record = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
            
            // Populate Record
            record.setValue(name, forKey: "name")
            
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

