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
     let FLICKR_GETPHOTOS_URL = "flickr.photos.search"
     let FLICKR_API = "3dbeb50b16947a85a6fc3a2a5c9cea03"
     let FLICKR_SECRET = "bee268e284df5611"
     
     let BOUNDING_BOX_HALF_WIDTH = 1.0
     let BOUNDING_BOX_HALF_HEIGHT = 1.0
     let LAT_MIN = -90.0
     let LAT_MAX = 90.0
     let LON_MIN = -180.0
     let LON_MAX = 180.0
     
     var pinLat: Double?
     var pinLong: Double?
     
     override init() {
          session = NSURLSession.sharedSession()
          super.init()
     }
     
     func searchLatLong(pin: Pin) {
          pinLat = pin.lat
          pinLong = pin.long
          var pageNum = 1
          
               let keyValuePairs = [
                    "method": FLICKR_GETPHOTOS_URL,
                    "api_key": FLICKR_API,
                    "bbox": createBoundingBoxString(),
                    //"safe_search": "1",
                    "extras": "url_m",
                    "format": "json",
                    "nojsoncallback": "1",
                    "page": "\(pageNum)"
               ]
               
               getImageFromFlickrBySearch(keyValuePairs)
     }
     
     func createBoundingBoxString() -> String {
      
          let latitude = pinLat
          let longitude = pinLong
          
          /* Fix added to ensure box is bounded by minimum and maximums */
          let bottom_left_lon = max(longitude! - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
          let bottom_left_lat = max(latitude! - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
          let top_right_lon = min(longitude! + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
          let top_right_lat = min(latitude! + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
          
          return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
     }
     
     
     func getImageFromFlickrBySearch(methodArguments: [String : AnyObject]) {
          
          /* 3 - Get the shared NSURLSession to faciliate network activity */
          //let session = NSURLSession.sharedSession()
          
          /* 4 - Create the NSURLRequest using properly escaped URL */
          let urlString = FLICKR_BASE_URL + escapedParameters(methodArguments)
          let url = NSURL(string: urlString)!
          let request = NSURLRequest(URL: url)
          
          /* 5 - Create NSURLSessionDataTask and completion handler */
          let task = session.dataTaskWithRequest(request) {data, response, downloadError in
               if let error = downloadError {
                    println("Could not complete the request \(error)")
               } else {
                    var parsingError: NSError? = nil
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                    
                    // store the parsed photos into a dictionary
                    if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                         
                         if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                              
                              // grab a random image index
                              let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                              
                              let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                              
                              // get the url and title from dictionary
                              
                              let photoTitle = photoDictionary["title"] as? String
                              let imageURLstring = photoDictionary["url_m"] as? String
                              let imageURL = NSURL(string: imageURLstring!)
                              
                              // if image exists, set the image and title
                              
                              /*
                              if let imageData = NSData(contentsOfURL: imageURL!) {
                                   dispatch_async(dispatch_get_main_queue(), {
                                        self.flickImage.image = UIImage(data: imageData)
                                        self.imageTitle.text = photoTitle
                                   })
                              } else {
                                   println("Image does not exist at \(imageURL)")
                              }
                              */
                              
                         } else {
                              println("Cannot find key 'photo' in \(photosDictionary)")
                         }
                         
                    } else {
                         println("Can't find key 'photos' in \(parsedResult)")
                    }
               }
          }
          
          /* 6 - Resume (execute) the task */
          task.resume()
     }
     
     
     func escapedParameters(parameters: [String : AnyObject]) -> String {
          
          var urlVars = [String]()
          
          for (key, value) in parameters {
               
               /* Make sure that it is a string value */
               let stringValue = "\(value)"
               
               /* Escape it */
               let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
               
               /* Append it */
               urlVars += [key + "=" + "\(escapedValue!)"]
               
          }
          
          return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
     }

     
     class func sharedInstance() -> FlickrClient {
          struct Singleton {
               static var sharedInstance = FlickrClient()
          }
          
          return Singleton.sharedInstance
     }
     
}
