//
//  SpotDetailViewController.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/3/21.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class SpotDetailViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var spot: Spot!
    
    let regionDistance: CLLocationDegrees = 750.0
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()

        if spot == nil{
            spot = Spot()
        }
        setupMapView()
        updateUserInterface()
    }
    
    func setupMapView(){
        let region = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }
    
    func updateUserInterface(){
        nameTextField.text = spot.name
        addressTextField.text = spot.address
        updateMap()
    }
    
    func updateFromInterface(){
        spot.name = nameTextField.text!
        spot.address = addressTextField.text!
    }
    
    func leaveViewController(){
        let isPresentingInAddMode =  presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        spot.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "The data not saving to cloud")
            }
        }
    }
    
    @IBAction func lookupButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
}

extension SpotDetailViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        spot.name = place.name ?? "Unknown Place"
        spot.address = place.formattedAddress ?? "Unknown Address"
        spot.coordinate = place.coordinate
        updateUserInterface()
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

  // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

//  // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }

}


extension SpotDetailViewController: CLLocationManagerDelegate {
    
    func getLocation(){
        //creating a CLLocationManager will automatially check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        print("Checking authentication status")
        handleAuthorizationStatus(status: status)
    }
    
    func handleAuthorizationStatus(status: CLAuthorizationStatus){
        switch status{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location services denies", message: "It may be that parental controls are restricting location use in this app")
        case .denied:
            showAlertToPrivacySetting(title: "User has not authorized location services", message: "Select 'Settings' below to enable location services for this app")
        
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("Unknown case of \(status)")
        }
        
    }
    
    func showAlertToPrivacySetting(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong getting UIApplication.openSettingsURLString")
            return
        }
        let settingAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        let currentLocation = locations.last ?? CLLocation()
        print("Current Location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        var name = ""
        var address = ""
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            //var locationName = ""
            if error != nil{
                print("ERROR: retreiving place. \(error!.localizedDescription)")
            }
            if placemarks != nil {
                let placemark = placemarks?.last
                name = placemark?.name ?? "Parts Unknown"
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            }else {
                print("ERROR: retreiving placemark.")
            }
            if self.spot.name == "" && self.spot.address == "" {
                self.spot.name = name
                self.spot.address = address
                self.spot.coordinate = currentLocation.coordinate
            }
            //why is it not showing the name in the white box???
            self.mapView.userLocation.title = name
            self.mapView.userLocation.subtitle = address.replacingOccurrences(of: "\n", with: ", ")
            self.updateUserInterface()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}
