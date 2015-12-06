//
//  Place.swift
//  MemorablePlaces
//
//  Created by Alejandro Galue on 12/6/15.
//  Copyright © 2015 Street Dog Studio. All rights reserved.
//

import Foundation
import CoreData

@objc(Place)
class Place: NSManagedObject {
    
    @NSManaged var name:String
    @NSManaged var address:String
    @NSManaged var latitude:Double
    @NSManaged var longitude:Double

}