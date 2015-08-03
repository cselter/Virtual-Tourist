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
     
     
     
     
     
     
     
}