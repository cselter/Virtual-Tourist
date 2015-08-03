//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 7/26/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation
import MapKit

class FlickrClient : NSObject {
     
     // Shared Session
     var session: NSURLSession
     
     
     let FLICKR_BASE_URL = "https://api.flickr.com/services/rest/"
     let FLICKR_API = "INSERT API HERE"
     
     
     
     
     
     
     
     
     override init() {
          session = NSURLSession.sharedSession()
          super.init()
     }
     
     
     
     
     
     
}
