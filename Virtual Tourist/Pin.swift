//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 7/26/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import MapKit
import CoreData

@objc(Pin)

class Pin: NSManagedObject {
     
     @NSManaged var title: String
     @NSManaged var subtitle: String
     @NSManaged var lat: Double
     @NSManaged var long: Double
     @NSManaged var photos: [Photo]
     
     @NSManaged var locationName: String

     override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
          super.init(entity: entity, insertIntoManagedObjectContext: context)
     }
     
     init(title: String, subtitle: String, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
          let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
          super.init(entity: entity, insertIntoManagedObjectContext: context)
          
          self.title = title
          self.lat = latitude
          self.long  = longitude
     }
     
     var pin: MKPointAnnotation {
          get {
               let annotation = MKPointAnnotation()
               let loc = CLLocationCoordinate2DMake(lat, long)

               annotation.coordinate = loc
               annotation.title = self.title
               return annotation
          }
     }
}