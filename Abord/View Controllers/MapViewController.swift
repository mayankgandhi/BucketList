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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationServices()
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
        }
    }
    
    func checkLocationAuthorisation()   {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
           break
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
            let region = placemark.locality ?? " "
            let country = placemark.country ?? " "
            let coordinate = placemark.location?.coordinate
            let pin = mapPin(title: region, subTitle: country, location:coordinate!)
            mapView.addAnnotation(pin)
            DispatchQueue.main.async {
                self.addressLabel.text = "\(region),\(country)"
            }
        }
    }
}
