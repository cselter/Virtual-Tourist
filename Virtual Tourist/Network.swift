//
//  Network.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 6/13/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import Foundation

// ****************************************************
// * Check for network connectivity before logging in *
// ****************************************************
public class Network {
     
     class func isConnectedToNetwork()->Bool{
          var Status:Bool = false
          let url = NSURL(string: "https://api.flickr.com")
          let request = NSMutableURLRequest(URL: url!)
          request.HTTPMethod = "HEAD"
          request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
          request.timeoutInterval = 5.0
          
          var response: NSURLResponse?
          
          var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
          
          if let httpResponse = response as? NSHTTPURLResponse {
               if httpResponse.statusCode == 200 {
                    Status = true
               }
          }
          
          return Status
     }
}