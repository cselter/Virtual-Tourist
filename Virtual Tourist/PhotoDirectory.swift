//
//  PhotoDirectory.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 10/16/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import UIKit

class PhotoDirectory {
     
     var documentManager = NSFileManager.defaultManager()
     
     // Returns image
     func photoWithID(identifier: String?) -> UIImage? {
          if identifier == nil || identifier != "" {
               return nil
          }
          
          let path = pathOfID(identifier!)
          if let data = NSData(contentsOfFile: path) {
               return UIImage(data: data)
          }
          return nil
     }
     

     
     // Creates a URL path from the name of the file
     func pathOfID(identifier: String) -> String {
          let documentDirectoryURL = documentManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
          let url = documentDirectoryURL.URLByAppendingPathComponent(identifier.lastPathComponent)
          
          
          return url.path!
     }
     
     // Save the image in the document directory of the user
     func savePhoto(image: UIImage?, withID identifier: String) {
          let path = pathOfID(identifier)
          if image == nil {
              do {
                  try documentManager.removeItemAtPath(path)
              } catch _ {
              }
               return
          }
          let data = UIImagePNGRepresentation(image!)
          data!.writeToFile(path, atomically: true)
     }
     
     // Deletes the image in the document directory 
     func deletePhoto(identifier: String) {
          var error: NSError?
          if documentManager.fileExistsAtPath(pathOfID(identifier)) {
              do {
                  try documentManager.removeItemAtPath(pathOfID(identifier))
              } catch let error1 as NSError {
                  error = error1
              }
          }
     }
}


extension String {
     var lastPathComponent: String {
          
          get {
               return (self as NSString).lastPathComponent
          }
     }
     
}