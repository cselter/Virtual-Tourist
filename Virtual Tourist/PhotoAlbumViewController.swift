//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 7/24/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
     @IBOutlet weak var navBar: UINavigationItem!
     @IBOutlet weak var mapView: MKMapView!
     
     var pin: Pin!
     var pinAnnotation: MKPointAnnotation?
     
     override func viewWillAppear(animated: Bool) {
          self.navigationController?.navigationBarHidden = false
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
          
          let pinLocation = CLLocationCoordinate2D(latitude: self.pin.lat, longitude: self.pin.long)
          let pin = MKPointAnnotation()
          pin.coordinate = pinLocation
          pin.title = self.pin.title
          self.pinAnnotation = pin
          var currPin = [MKPointAnnotation]()
          self.mapView.showAnnotations([pin], animated: true)
     }

     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
     
     
     
     func helloMap() {
          
          let client = FlickrClient.sharedInstance()

          
          
          
          // Test for network connectivity
          dispatch_async(dispatch_get_main_queue()) {
               if Network.isConnectedToNetwork() == false {
                    var noConnectivity = UIAlertView()
                    noConnectivity.title = "Unable to Connect"
                    noConnectivity.message = "Please connect to the Internet."
                    noConnectivity.addButtonWithTitle("OK")
                    noConnectivity.show()
               }
          }
          
     }
     
     
     
}

