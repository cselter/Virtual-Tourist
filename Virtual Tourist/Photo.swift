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
     
     struct properties {
          static let URL = "url_m"
          static let TITLE = "title"
     }
     
     @NSManaged var photoImage: UIImage?
     @NSManaged var photoPath: String?
     @NSManaged var photoTitle: String?
     @NSManaged var pin: Pin?
     
     
     override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
          super.init(entity: entity, insertIntoManagedObjectContext: context)
     }
     
     init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
          
          let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
          super.init(entity: entity, insertIntoManagedObjectContext: context)
          

          self.photoPath = dictionary[properties.URL] as? String
          self.photoTitle = dictionary[properties.TITLE] as? String
     }
     
     var docDirectoryImage: UIImage? {
          get {
               return FlickrClient.FileAccessory.photoAccessor.photoWithID(photoPath)
          }
          set {
               FlickrClient.FileAccessory.photoAccessor.savePhoto(newValue, withID: photoPath!)
          }
     }
     
     override func prepareForDeletion() {
          FlickrClient.FileAccessory.photoAccessor.deletePhoto(self.photoPath!)
     }
     
}