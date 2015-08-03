//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Christopher Burgess on 7/24/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var navBar: UINavigationItem!

     override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
          
          self.mapView.delegate = self
          
          var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
          
          longPressRecogniser.minimumPressDuration = 1.0
          mapView.addGestureRecognizer(longPressRecogniser)
     }

     override func viewWillAppear(animated: Bool) {
          self.navigationController?.navigationBarHidden = true
     }
     
     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }

     // *************************************
     // * Configure & Add Pin On Long Press *
     // *************************************
     func handleLongPress(getstureRecognizer : UIGestureRecognizer){
          if getstureRecognizer.state != .Began { return }
          
          let touchPoint = getstureRecognizer.locationInView(self.mapView)
          let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
          
          let annotation = MKPointAnnotation()
          annotation.coordinate = touchMapCoordinate
          
          let geocode = CLGeocoder()
          let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
          
          geocode.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
               
               
               let placeArray = placemarks as? [CLPlacemark]
               
               // Place details
               var placeMark: CLPlacemark!
               placeMark = placeArray?[0]
               
               // Address dictionary
               // println(placeMark.addressDictionary)
               
               // Location name
               if let locationName = placeMark.addressDictionary["Name"] as? NSString {
                    print("locationName: ")
                    println(locationName)
                    
                    annotation.title = locationName as String
               } else {
                    // City
                    if let city = placeMark.addressDictionary["City"] as? NSString {
                         print("city: ")
                         println(city)
                         annotation.title = city as String
                    }
                    
                    // State
                    if let state = placeMark.addressDictionary["State"] as? NSString {
                         print("state: ")
                         println(state)
                         annotation.title = annotation.title + " " + (state as String)
                    }
               }
          })

          mapView.addAnnotation(annotation)
     }

     // *************************************************
     // * Configure annotation view of the student Pins *
     // *************************************************
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
          
          // let photoAlbumVC = PhotoAlbumViewController
          
          self.performSegueWithIdentifier("OpenPhotoAlbumVC", sender: self)
          
     }

     
     
     func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
          println("tap tap")
     }
     
}

