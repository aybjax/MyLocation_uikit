//
//  ViewController.swift
//  MyLocations
//
//  Created by aybjax on 6/1/21.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController,
                                     CLLocationManagerDelegate{
    
    // Properties
    // ==========
    var managedObjectContext: NSManagedObjectContext!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var updatingLocation = false
    var lastLocationError: Error?
    
    // for reverse geocoding
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        
        // cannot get window.rootViewController from Scene/App delegate
//        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        // corrected for scene delegate but below is with dependency injection
//        let scene: UIScene = UIApplication.shared.connectedScenes.first!
//
//        let delegate: SceneDelegate = scene.delegate as! SceneDelegate
//
//        managedObjectContext = delegate.managedObjectContext
        
        
        
        print(applicationDocmentsDirectory)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    // Methods
    // =======
    
    @IBAction func getLocation() {
//        let authStatus = CLLocationManager.authorizationStatus()
        
        let authStatus = locationManager.authorizationStatus
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            
            return
        }
        
        
        if updatingLocation {
            stopLocationManager()
        } else {
            placemark = nil
            lastLocationError = nil
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        
        updateLabels()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert  = UIAlertController(title: "Location Services Disabled",
                                       message: "Please enable location services for this app in Settings",
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            }
            else if performingReverseGeocoding {
                addressLabel.text = "Searching for Adress..."
            }
            else if lastLocationError != nil {
                addressLabel.text = "Error Finding Address"
            }
            else {
                addressLabel.text = "No Address Found"
            }
        }
        else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                }
                else {
                    statusMessage = "Error Getting Location"
                }
            }
            else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Searching..."
            }
            else {
                statusMessage = "Tap `Get My Location` to Start"
            }
            
            messageLabel.text = statusMessage
        }
        
        configureGetButton()
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        
        if let s = placemark.locality {
            line2 += s + " "
        }
        
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    
    @IBAction func tagLocation() {
    //
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
        else {
            print("Missed it")
        }
    }
    
    // delegate
    // ========
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        print("    **** horizontal \(newLocation.horizontalAccuracy)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            print("    **** cached")
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** ✅ We're done")
                
                stopLocationManager()
            }
            
            updateLabels()
        }
        
        location = newLocation
        
        lastLocationError = nil
        updateLabels()
        
        if !performingReverseGeocoding {
            print("*** Going to geocode")
            
            performingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                placemark, error in
//                if let error = error {
//                    print("*** Reverse Geocoing error: \(error.localizedDescription)")
//
//                    return
//                }
//
//                if let places = placemark {
//                    print("*** Found places: \(places)")
//                }
                self.lastLocationError = error
                
                if error == nil, let p = placemark, !p.isEmpty {
                    //for faking crash
//                    self.placemark = p.last!
                } else {
                    self.placemark = nil
                }
                
                self.performingReverseGeocoding = false
                self.updateLabels()
            })
        }
    }
}


