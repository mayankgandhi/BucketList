//
//  MapViewController.swift
//  Abord
//
//  Created by Mayank on 31/03/20.
//  Copyright © 2020 Mayank. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class mapPin: NSObject, MKAnnotation    {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title:String?, subTitle:String?, location:CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = location
        self.subtitle = subTitle
    }
}

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    var previousLocation:CLLocation?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var region:String!
    var country:String!
    var coordinate:CLLocationCoordinate2D?
    var bucketPins=[PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadBucketListPins()
    }
    
    private func loadBucketListPins()   {
        let query = PFQuery(className: "BucketList")
        query.whereKey("author", equalTo: PFUser.current())
        //For Example, if you only want to query the last 20
        query.limit = 20
        query.findObjectsInBackground { (pins,Error) in
            if pins != nil{
                self.bucketPins = pins!
                self.showBucketPins()
            }   else    {
                print(Error?.localizedDescription)
            }
        }
    }
    
    private func showBucketPins()   {
        for bucketPin in bucketPins {
            let title = bucketPin["title"]
            let subtitle = bucketPin["subTitle"]
            let latitude = bucketPin["latitude"] as! Double
            let longitude = bucketPin["longitude"] as! Double
            let location = CLLocationCoordinate2D.init(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
            let pin = mapPin(title: title as! String, subTitle: subtitle as! String, location: location)
            mapView.addAnnotation(pin)
        }
    }
    
    @IBAction func zoomMap(_ sender: UIStepper) {
        let region = MKCoordinateRegion.init(center: coordinate!, latitudinalMeters: 10000*sender.value, longitudinalMeters: 10000*sender.value)
        mapView.setRegion(region, animated: true)
    }
    
    
    func setupLocationServices()    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices()    {
        if CLLocationManager.locationServicesEnabled()  {
            //if Location Services enabled, setup Location Manager
            setupLocationServices()
            checkLocationAuthorisation()
        }   else    {
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            coordinate = locationManager.location?.coordinate
        }
    }
    
    func checkLocationAuthorisation()   {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            startTrackingUserLocation()
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            break
        case .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func addMapPin(_ sender: Any) {
        addMapPinAnnotation()
    }
    
    func startTrackingUserLocation()    {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func getCenterLocation( for mapView:MKMapView)  -> CLLocation   {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    
}

extension MapViewController:CLLocationManagerDelegate   {
    //  Keep following the current location as the center of the screen
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        guard let location = locations.last else { return }
    //        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
    //        mapView.setRegion(region, animated: true)
    //    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorisation()
    }
}

extension MapViewController:MKMapViewDelegate   {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard let previousLocation = self.previousLocation else { return }
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation=center
        geoCoder.reverseGeocodeLocation(center) { [weak self] ( placemarks, Error) in
            guard let self = self else { return }
            if let error = Error {
                return
            }
            guard let placemark = placemarks?.first else     {
                return
            }
            self.region = placemark.locality ?? " "
            self.country = placemark.country ?? " "
            self.coordinate = placemark.location?.coordinate
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(placemark.locality ?? " "), \(placemark.country ?? " ")"
            }
        }
    }
    
    private func addMapPinAnnotation() {
        let pin = mapPin(title: region, subTitle: country, location:coordinate!)
        mapView.addAnnotation(pin)
        storeMapPinAnnotationToUser(title: region!, subTitle: country!, location:coordinate!)
        
    }
    private func storeMapPinAnnotationToUser(title:String, subTitle:String, location:CLLocationCoordinate2D)    {
        
        let bucketPin = PFObject(className: "BucketList")
        bucketPin["author"] = PFUser.current()!
        bucketPin["title"] = title
        bucketPin["subTitle"] = subTitle
        bucketPin["latitude"] = location.latitude
        bucketPin["longitude"] = location.longitude
        bucketPin.saveInBackground { (success, error) in
            if (error != nil) {
                print(error?.localizedDescription)
            } else  {
                print("pinSaved")
            }
        }
    }
}
