//
//  MapViewController.swift
//  MyDiscoveryRoute
//
//  Created by selinay ceylan on 15.04.2025.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var getDirectionsButton: UIButton!
    @IBOutlet weak var showUserLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var location: Location?
    private let locationManager = CLLocationManager()
    private var userAskedForLocation = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        setupUI()
        
                locationManager.delegate = self
                mapView.delegate = self
                
                checkInitialLocationPermission()
    }
    
    func setupUI() {
        if let locationName = location?.name {
            title = locationName
        }
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
  
        getDirectionsButton.layer.cornerRadius = 8
        getDirectionsButton.backgroundColor = .systemBlue
        getDirectionsButton.setTitle("Yol Tarifi Al", for: .normal)
        getDirectionsButton.setTitleColor(.white, for: .normal)
        
       
        showUserLocationButton.layer.cornerRadius = 8
        showUserLocationButton.backgroundColor = .systemGray
        showUserLocationButton.setTitle("Konumumu Göster", for: .normal)
        showUserLocationButton.setTitleColor(.white, for: .normal)
    }
    
    func setupMap() {
          guard let location = location else { return }
          
      
          let coordinate = CLLocationCoordinate2D(
              latitude: location.coordinates.lat,
              longitude: location.coordinates.lng
          )
          
     
          let annotation = MKPointAnnotation()
          annotation.coordinate = coordinate
          annotation.title = location.name
          mapView.addAnnotation(annotation)
          
  
          let region = MKCoordinateRegion(
              center: coordinate,
              span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
          )
          mapView.setRegion(region, animated: true)
      }
    
    @objc func backButtonTapped() {
          navigationController?.popViewController(animated: true)
      }
    
    func checkInitialLocationPermission() {
         let status = CLLocationManager.authorizationStatus()
         
         switch status {
         case .authorizedWhenInUse, .authorizedAlways:
     
             mapView.showsUserLocation = true
             locationManager.startUpdatingLocation()
             
         case .notDetermined:
 
             showInitialLocationPermissionAlert()
             
         case .denied, .restricted:
           
             break
             
         @unknown default:
             break
         }
     }
    func checkLocationPermissionForButton() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
      
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            
            if let userLocation = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                mapView.setRegion(region, animated: true)
            }
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            showLocationSettingsAlert()
            
        @unknown default:
            break
        }
    }
    
    func showInitialLocationPermissionAlert() {
         let alert = UIAlertController(
             title: "Konum İzni",
             message: "Kendi konumunu haritada görmek ister misin?",
             preferredStyle: .alert
         )
         
         alert.addAction(UIAlertAction(title: "Evet", style: .default) { [weak self] _ in
             self?.locationManager.requestWhenInUseAuthorization()
         })
         
         alert.addAction(UIAlertAction(title: "Hayır", style: .cancel))
         
         present(alert, animated: true)
     }
    
    func showLocationSettingsAlert() {
        let alert = UIAlertController(
            title: "Konum İzni Gerekli",
            message: "Konumunuzu görebilmek için lütfen ayarlardan konum iznini etkinleştirin.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ayarlara Git", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func checkGPSStatus() {
        if #available(iOS 14.0, *) {
            if locationManager.accuracyAuthorization == .reducedAccuracy {
                showGPSAccuracyAlert()
            }
        }
    }
    
    func showGPSAccuracyAlert() {
        let alert = UIAlertController(
            title: "Konum Doğruluğu",
            message: "Daha doğru konum bilgisi için tam hassasiyet izni vermeniz önerilir.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ayarlara Git", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        present(alert, animated: true)
    }
    

    @IBAction func showUserLocation(_ sender: Any) {
               checkLocationPermissionForButton()
    }
    
    @IBAction func getDirections(_ sender: Any) {
        guard let location = location else { return }
               
               let coordinate = CLLocationCoordinate2D(
                   latitude: location.coordinates.lat,
                   longitude: location.coordinates.lng
               )
               
               let placemark = MKPlacemark(coordinate: coordinate)
               let mapItem = MKMapItem(placemark: placemark)
               mapItem.name = location.name
               

               let launchOptions = [
                   MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
               ]
               
               mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      
           if status == .authorizedWhenInUse || status == .authorizedAlways {
               mapView.showsUserLocation = true
               locationManager.startUpdatingLocation()
               checkGPSStatus()
           }
       }
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      
        if annotation is MKUserLocation {
            return nil
        }
        

        let identifier = "locationMarker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
   
        if let markerView = annotationView as? MKMarkerAnnotationView {
            markerView.glyphImage = UIImage(systemName: "star.fill")
            markerView.markerTintColor = .systemYellow
        }
        
        return annotationView
    }
}
