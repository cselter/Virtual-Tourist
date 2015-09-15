//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 7/24/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var navBar: UINavigationItem!

     var storedPins = [Pin]() // existing pins found in Core Data (loaded during viewWillAppear())
     var currentPin: MKPointAnnotation?
     var foundPin: Pin?
     
     override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
          
          self.mapView.delegate = self
          
          var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
          
          longPressRecogniser.minimumPressDuration = 1.0
          mapView.addGestureRecognizer(longPressRecogniser)
          
          fetchedResultsController.performFetch(nil)
          fetchedResultsController.delegate = self
     }

     override func viewWillAppear(animated: Bool) {
          super.viewWillAppear(animated)
          self.mapView.removeAnnotations(mapView.annotations)
          // check for existing Pins in Core Data
          // and populate them on the map
          self.storedPins = self.fetchAllPins()
          
          if self.storedPins.count > 0 {
               
               var existingPins = [MKPointAnnotation]()
               for x in self.storedPins {
                    existingPins.append(x.pin)
               }

               dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mapView.showAnnotations(existingPins, animated: true)
               })
          }
          self.navigationController?.navigationBarHidden = true
     }
     
     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
  
     // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
     var sharedContext: NSManagedObjectContext {
          return CoreDataStackManager.sharedInstance().managedObjectContext!
     }
     
     // ******************************************
     // * Lazy fetchedResultsController property *
     // ******************************************
     lazy var fetchedResultsController: NSFetchedResultsController = {
          let fetchRequest = NSFetchRequest(entityName: "Pin")
          
          fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
          
          let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
          
          return fetchedResultsController
     } ()
     
     // *************************************
     // * Configure & Add Pin On Long Press *
     // *************************************
     func handleLongPress(getstureRecognizer : UIGestureRecognizer){
          if getstureRecognizer.state != .Began { return }
          
          let touchPoint = getstureRecognizer.locationInView(self.mapView)
          let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
          
          let annotation = MKPointAnnotation()
          annotation.coordinate = touchMapCoordinate
          
          let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
          revGeoLocation(location, pinAnnotation: annotation)
     }

     // ****************************
     // * Reverse Geocode Location *
     // ****************************
     func revGeoLocation(loc: CLLocation, pinAnnotation: MKPointAnnotation) {
          let geocoder = CLGeocoder()
          
          geocoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) -> Void in
               let placeArray = placemarks as? [CLPlacemark]
               
               // Place details
               var placeMark: CLPlacemark!
               placeMark = placeArray?[0]
               
               // Address dictionary
               // println(placeMark.addressDictionary)
               
               if let locationName = placeMark.addressDictionary["Name"] as? NSString {
                    pinAnnotation.title = locationName as String
                    
               }
               // Add the new Pin to the MapView
               self.addNewPin(MKPlacemark(placemark: placeMark))
          })
     }
     
     // **********************************
     // * Add the new Pin to the MapView *
     // **********************************
     func addNewPin(pinLocation: MKPlacemark) {
          let newPinLat = pinLocation.coordinate.latitude as Double
          let newPinLong = pinLocation.coordinate.longitude as Double
          let pinCoordinate = CLLocationCoordinate2D(latitude: newPinLat, longitude: newPinLong)
          let newPin = MKPointAnnotation()

          newPin.coordinate = pinCoordinate
          newPin.title = pinLocation.name
          newPin.subtitle = pinLocation.subLocality
          
          dispatch_async(dispatch_get_main_queue(), { ()->Void in
               self.mapView.addAnnotation(newPin)
               self.mapView.showAnnotations([newPin], animated: true)
          })
          
          let newPinTitle = newPin.title ?? "Unknown Location"
          let newPinSubTitle = newPin.subtitle ?? ""
          
          let addPin = Pin(title: newPinTitle, subtitle: newPinSubTitle, latitude: newPinLat, longitude: newPinLong, context: self.sharedContext)
          CoreDataStackManager.sharedInstance().saveContext()
     }
     
     // *****************************************
     // * Configure annotation view of the Pins *
     // *****************************************
     func mapView(mapView: MKMapView!,
          viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
               
               if annotation is MKUserLocation {
                    //return nil so map view draws "blue dot" for standard user location
                    return nil
               }
               
               let reuseId = "pin"
               var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
               if pinView == nil {
                    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    pinView!.canShowCallout = true
                    pinView!.animatesDrop = true
                    pinView!.pinColor = .Red
                    pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
               }
               else {
                    pinView!.annotation = annotation
               }
               
               return pinView
     }
     
     // ***************************************************
     // * Open Photo Album View when annotation is tapped *
     // ***************************************************
     func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
          
          println("Tapped Annotation - Go to PhotoAlbumVC")
          // get the tapped Pin
          self.currentPin = mapView.selectedAnnotations.first as? MKPointAnnotation
          
          // get the lat and long of the tapped Pin
          let lat = NSNumber(double: (self.currentPin?.coordinate.latitude)! as Double)
          let long = NSNumber(double: (self.currentPin?.coordinate.longitude)! as Double)

          self.foundPin = fetchSinglePin(lat.doubleValue, long: long.doubleValue)
          
          self.performSegueWithIdentifier("OpenPhotoAlbumVC", sender: self)
     }

     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
          let photoMap = segue.destinationViewController as! PhotoAlbumViewController
          
          // set the Pin in the PhotoAlbumVC
          photoMap.pin = self.foundPin
     }
     
     // **************************
     // * When a user taps a pin *
     // **************************
     func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
          println("Selected a Pin")
     }
     
     // **************************
     // * Fetches all saved Pins *
     // **************************
     func fetchAllPins() -> [Pin] {
          let error: NSErrorPointer = nil
          let fetchRequest = NSFetchRequest(entityName: "Pin")
          let results = self.sharedContext.executeFetchRequest(fetchRequest, error: error)
          
          if error != nil {
               println("fetchAllPins() error: \(error)")
          }
          
          return results as! [Pin]
     }
     
     // **********************************************
     // * Fetches single Pin by lat/long coordinates *
     // **********************************************
     func fetchSinglePin(lat: Double, long:Double) -> Pin? {
          let error: NSErrorPointer = nil
          let fetchRequest = NSFetchRequest(entityName: "Pin")
          
          let pinLat = "\(lat)"
          let pinLong = "\(long)"

          let latPredicate = NSPredicate(format: "lat == %@", pinLat)
          let longPredicate = NSPredicate(format: "long == %@", pinLong)
          let latLongPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([latPredicate, longPredicate])
          
          fetchRequest.predicate = latLongPredicate
          fetchRequest.sortDescriptors = []
          let pinsArray = self.sharedContext.executeFetchRequest(fetchRequest, error: error) as! [Pin]
          if error != nil {
               println("fetchSinglePin() error: \(error)")
          }

          let foundCDPin = self.sharedContext.executeFetchRequest(fetchRequest, error: error)?.first as! Pin
          
          if error != nil {
               return nil
          }
          
          return foundCDPin // return the Pin found in Core Data
     }
}

