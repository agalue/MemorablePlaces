//
//  TableViewController.swift
//  Memorable Places
//
//  Created by Alejandro Galue on 11/29/15.
//  Copyright © 2015 Street Dog Studio. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Fetched Results Controller
        if fetchedResultsController == nil {
            initalizeFetchedResultsController()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func initalizeFetchedResultsController() {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: allPlacesFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("\(error)")
        }
    }
    
    // Initialize Fetch Request
    func allPlacesFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeCell", forIndexPath: indexPath) as! PlaceViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Fetch Record
            let record = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            // Delete Record
            managedObjectContext.deleteObject(record)
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // TODO I have to investigate how to do this with Core Data and Fetch Request Order
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }
    
    // MARK: - NSFetchedResultsController Delegate Functions
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Update:
            if let indexPath = indexPath {
                print("Updating row at \(indexPath.row)")
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlaceViewCell
                configureCell(cell, atIndexPath: indexPath)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Insert:
            if let indexPath = newIndexPath {
                print("Inserting row at \(indexPath.row)")
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    print("Moving row from \(indexPath.row) to \(newIndexPath.row)")
                    tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
                }
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                print("Deleting row at \(indexPath.row)")
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            }
            break;
        }
    }
    
    func configureCell(cell: PlaceViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let place = fetchedResultsController.objectAtIndexPath(indexPath) as! Place
        print("Configuring cell for \(place.name)")
        // Update Cell
        cell.update(place)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueAddPlaceViewController" {
            if let viewController = segue.destinationViewController as? EditPlaceViewController {
                viewController.managedObjectContext = self.managedObjectContext
            }
        }
        if segue.identifier == "segueEditPlaceViewController" {
            if let viewController = segue.destinationViewController as? EditPlaceViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // Fetch Record
                    let place = fetchedResultsController.objectAtIndexPath(indexPath) as! Place
                    // Configure View Controller
                    viewController.place = place
                    viewController.managedObjectContext = self.managedObjectContext
                }
            }
        }
        if segue.identifier == "segueMapViewController" {
            if let viewController = segue.destinationViewController as? MapViewController {
                viewController.managedObjectContext = self.managedObjectContext
            }
        }
    }
    
}
