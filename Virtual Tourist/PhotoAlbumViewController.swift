//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 7/24/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
     @IBOutlet weak var navBar: UINavigationItem!
     
     @IBOutlet weak var mapView: MKMapView!
     
     override func viewWillAppear(animated: Bool) {
          self.navigationController?.navigationBarHidden = false
     }
     
     
     override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
   

     }

     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
     
     
}

