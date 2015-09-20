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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
     @IBOutlet weak var navBar: UINavigationItem!
     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var photoCollectionView: UICollectionView!
     @IBOutlet weak var newCollectionButton: UIBarButtonItem!
     
     var pin: Pin!
     var pinAnnotation: MKPointAnnotation?
     let client = FlickrClient.sharedInstance()
     
     
     
     override func viewWillAppear(animated: Bool) {
          self.navigationController?.navigationBarHidden = false
          
          
          getPhotos()
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
          
          self.photoCollectionView.delegate = self
          self.photoCollectionView.dataSource = self
     }

     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
     }
     
     
     
     func getPhotos() {
          var countOfPhotos = 0
          // If this pin has no photos
          if self.pin.photos.isEmpty {
               println("pin.photos.isEmpty == true")
               self.client.searchLatLong(self.pin!, completionHandler: { (success, result, error) -> Void in
                    
                    if let error = error {
                         println("Error getting photos: \(error)")
                    } else {
                         
                         
                         // No error, got dictionary of photos
                         
                         // Need to save as Photo objects and save to Pin
                         
                         
                         
                         
                         
                         
                    }
                    
                    
                    
                    
                    
               })
               
               
               
               
               
               
          } else {
               self.newCollectionButton.enabled = true
          }
          
          
          
     }
     
     
     
     
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
          let photoCell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCellVC
          
        
          
     
          
     }
     
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return 0
          
     }
     
     
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
          return 0
     }
     
     
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
          let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCellVC
          
          let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
          
          
          
          
          return photoCell
     }
     
     
     
     
     
     
     
     
     
     
     // ******************************************
     // * Lazy fetchedResultsController property *
     // ******************************************
     lazy var fetchedResultsController: NSFetchedResultsController = {
          let fetchRequest = NSFetchRequest(entityName: "Photo")
          
          fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
          fetchRequest.sortDescriptors = []
          
          let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
          
          return fetchedResultsController
     } ()
     
     // **************************************************
     // * sharedContext property - Core Data Convenience *
     // **************************************************
     var sharedContext: NSManagedObjectContext {
          return CoreDataStackManager.sharedInstance().managedObjectContext!
     }
}

