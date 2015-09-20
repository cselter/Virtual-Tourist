//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 7/26/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)

class Photo: NSManagedObject {
     
     
     
     @NSManaged var photoImage: UIImage?
     @NSManaged var photoPath: String?
     @NSManaged var pin: Pin?
     
     
     override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
          super.init(entity: entity, insertIntoManagedObjectContext: context)
     }
     
     
     init(photoPath: String, pin: Pin, context: NSManagedObjectContext) {
          let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
          super.init(entity: entity, insertIntoManagedObjectContext: context)
          

          self.photoPath = photoPath
          self.pin  = pin
     }
     
     // var photoImage
     
     
}