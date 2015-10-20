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
     @IBOutlet weak var noPhotosLabel: UILabel!
     
     var pin: Pin!
     var pinAnnotation: MKPointAnnotation?
     let client = FlickrClient.sharedInstance()
     
     var selectedPhotoPaths = [NSIndexPath]()
     
     override func viewWillAppear(animated: Bool) {
          self.navigationController?.navigationBarHidden = false
          print("viewDidAppear")
          self.newCollectionButton.enabled = false
          
          self.noPhotosLabel.textAlignment = NSTextAlignment.Center
          self.noPhotosLabel.alpha = 0
     }

     override func viewDidLoad() {
          super.viewDidLoad()
          print("viewDidLoad")
          let pinLocation = CLLocationCoordinate2D(latitude: self.pin.lat, longitude: self.pin.long)
          let pin = MKPointAnnotation()
          pin.coordinate = pinLocation
          pin.title = self.pin.title
          self.pinAnnotation = pin
          // var currPin = [MKPointAnnotation]()
          self.mapView.showAnnotations([pin], animated: true)
          
          do {
              try fetchedResultsController.performFetch()
          } catch _ {
          }
          
          fetchedResultsController.delegate = self
          self.photoCollectionView.delegate = self
          self.photoCollectionView.dataSource = self
          
          if self.pin.photos.isEmpty {
               getPhotos()
               print("getPhotos() called")
          } else {
               self.newCollectionButton.enabled = true
          }
     }

     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
     }
     
     // *************************************
     // * newCollectionButtonPressed Method *
     // *************************************
     @IBAction func newCollectionButtonPressed(sender: AnyObject) {
          self.newCollectionButton.enabled = false
          // delete current photos
          deletePhotoCollection()
          // getPhotos()
          getPhotos()
          //photoCollectionView.reloadData()
     }
     
     // ********************
     // * getPhotos Method *
     // ********************
     func getPhotos() {
          var countOfPhotos = 0
          // If this pin has no photos
          if self.pin.photos.isEmpty {
               self.client.searchLatLong(self.pin!, completionHandler: { (success, result, error) -> Void in
                    
                    if let error = error {
                         print("Error getting photos: \(error)")
                    } else {
                         // No error, got dictionary of photos
                         // Save as Photo objects and save to Pin
                         //println(result)
                         if let photosDictionary = result as? [[String: AnyObject]] {
                              countOfPhotos = photosDictionary.count
                              print("countOfPhotos: \(countOfPhotos)")
                              
                              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                              var photos = photosDictionary.map() {
                                   (dictionary: [String: AnyObject]) -> Photo in
                                   print("before let photo")
                                   
                                 
                                   
                                   let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                 
                                   
                                   photo.pin = self.pin
                                   return photo
                              }
                                   })
                              
                              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                   if countOfPhotos > 0 {
                                        self.noPhotosLabel.alpha = 0
                                        self.newCollectionButton.enabled = true
                                        // println("calling reloadData()1...")
                                        //self.photoCollectionView.reloadData()
                                   } else {
                                        //self.noPhotoLabel.hidden = false
                                   }
                              })
                              
                         } else {
                              print("else, error")
                              if let error = result as? String {
                              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                   // TODO: Update ERROR Popup
                                   // self.displayUIAlertController("Error getting photos", message: "\(error)", action: "Ok")
                              })
                              }
                         }
                         print("***********calling saveContext()...")
                         dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                   self.saveIt()
                              })
                         self.newCollectionButton.enabled = true
                    }
               })
          } else {
               self.newCollectionButton.enabled = true
          }
          
          if countOfPhotos == 0 {
               self.noPhotosLabel.alpha = 1
          }
     }
     
     // ********************************************
     // * collectionView: didSelectItemAtIndexPath *
     // ********************************************
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
          print("didSelectItemAtIndexPath")
          let photoCell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCellVC
          
          if let index = selectedPhotoPaths.indexOf(indexPath) {
               selectedPhotoPaths.removeAtIndex(index)
          } else {
               selectedPhotoPaths.append(indexPath)
          }
          
          self.deleteSelectedPhoto()
     }

     // ******************************************
     // * collectionView: numberOfItemsInSection *
     // ******************************************
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          let sectionData = self.fetchedResultsController.sections![section] 
          
          print("numberOfItemsInSection: \(sectionData.numberOfObjects)")
          return sectionData.numberOfObjects
     }

     // ***********************************************
     // * return number of sections in CollectionView *
     // ***********************************************
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
          print("numberOfSectionsInCollectionView: \(self.fetchedResultsController.sections?.count)")
          return self.fetchedResultsController.sections?.count ?? 0
     }
     
     // ******************************************
     // * collectionView: cellForItemAtIndexPath *
     // ******************************************
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
          print("cellForItemAtIndexPath")
          let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCellVC
          let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
          photoCell.cellImageView.image = UIImage(named: "VirtualTourist_120")
          prepPhotoCell(photoCell, photo: photo)
          return photoCell
     }
     
     // *****************************************
     // * prepPhotoCell: Abstracted cell config *
     // *****************************************
     func prepPhotoCell(photoCell: PhotoCellVC, photo: Photo) {
          let photoImage = UIImage(named: "VirtualTourist_120")
          photoCell.cellImageView.image = nil
          
          if photo.photoPath == nil || photo.photoPath == "" {   // use 'blank photo', if nil/empty
               print("photoPath is nil or empty")
               photoCell.cellImageView.image = UIImage(named: "VirtualTourist_120")
          } else {
               let task = FlickrClient.sharedInstance().getFlickrImageData(photo.photoPath!) {
                    (imageData, error) -> Void in
                    
                    if let error = error {
                         dispatch_async(dispatch_get_main_queue(), { () -> Void in
                              print("error: \(error)")
                         })
                    } else {
                         if let data = imageData {
                              let image = UIImage(data: data)
                              
                              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                   photo.docDirectoryImage = image
                              })
                              
                              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                   //photo.docDirectoryImage = photoImage
                                   photoCell.cellImageView.image = image
                              })
                              self.newCollectionButton.enabled = true
                         }
                    }
               }
          }
          photoCell.cellImageView.image = photoImage!
     }
     
     
     // ****************************************************
     // * Refreshes the collection if any changes are made *
     // ****************************************************
     func controllerWillChangeContent(controller: NSFetchedResultsController) {
          print("calling reload data in controllerwillchangecontent")
          self.photoCollectionView.reloadData()
     }
     
     // ************************************************
     // * Deletes selected photo in collection for pin *
     // ************************************************
     func deleteSelectedPhoto() {
          var photoToDel = [Photo]()
          
          for indexPath in self.selectedPhotoPaths {
               photoToDel.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
          }
          
          for photo in photoToDel {
               sharedContext.deleteObject(photo)
               self.saveIt()
          }
          self.selectedPhotoPaths = [NSIndexPath]()
          self.newCollectionButton.enabled = true
     }
     
     // ********************************************
     // * Deletes all photos in collection for pin *
     // ********************************************
     func deletePhotoCollection() {
          for image in fetchedResultsController.fetchedObjects as! [Photo] {
               sharedContext.deleteObject(image)
          }
          self.saveIt()
     }
     
     // ******************************************
     // * Lazy fetchedResultsController property *
     // ******************************************
     lazy var fetchedResultsController: NSFetchedResultsController = {
          let fetchRequest = NSFetchRequest(entityName: "Photo")
          
          fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
          
          let sortDesc = NSSortDescriptor(key: "photoTitle", ascending: true)
          let sortDescs = [sortDesc]
          fetchRequest.sortDescriptors = sortDescs

          let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
          
          return fetchedResultsController
     } ()
     
     // **************************************************
     // * sharedContext property - Core Data Convenience *
     // **************************************************
     var sharedContext: NSManagedObjectContext {
          return CoreDataStackManager.sharedInstance().managedObjectContext!
     }
     
     // ************************************************
     // * saveContext function - Core Data Convenience *
     // ************************************************
     func saveIt() {
          CoreDataStackManager.sharedInstance().saveContext()
     }
}

