//
//  MapViewController.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-26.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager!
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var centerMap: UIButton!
    
    //Base setup, GPS to IBM Malmö
    var localtion_lat = 55.611868
    var location_long = 12.977738
    
    var pinCoords : [Double] = [0.0]
    var pinLat : Double = 0.0
    var pinLng : Double = 0.0
    var pinColor : String = ""
    var pinCounter : Int = 0
    var pinTitle : String = ""
    var pinSubTitle : String = ""
    
    var ownPin = OwnPin()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

        mainMapView.delegate = self
        mainMapView.isRotateEnabled = false
        moveMap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(runRequest(notfication:)), name: .updateMap, object: nil)
        
        print("added notificationObserver")
        
    }

    @objc func runRequest(notfication: NSNotification) {
        getPins()
    }
    
    func getPins () {
        let url = URL(string: "https://blighttoaster.eu-gb.mybluemix.net/api/blight_per_point")
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            var coordsCounter : Int = 0
            var colorCounter : Int = 0
            var dateCounter : Int = 0
            var maxBlightCounter : Int = 0
            
            if response != nil {
//                print("This is respons: ", response)
            }
            
            if error != nil {
                print("This is error: ", error)
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                            
                            if let features = jsonObj!.value(forKey:"features") as? NSArray {
                                
                                for _ in features{
                                    
                                    
                                    if let geometry = features.value(forKey:"geometry") as? NSArray {
                                        
                                        if let coordinates = geometry.value(forKey:"coordinates") as? NSArray {
                                            
                                            self.pinCoords = coordinates[coordsCounter] as! [Double]
                                            coordsCounter += 1
                                            
                                            self.pinLng = self.pinCoords[0]
                                            self.pinLat = self.pinCoords[1]
                                            
                                        }
                                    }
                                    if let properties = features.value(forKey:"properties") as? NSArray {
                                        
                                        if let color = properties.value(forKey: "colour") as? [String] {
                                            
                                            self.pinColor = color[colorCounter] as String
                                            colorCounter += 1
                                            
                                        }
                                        
                                        if let dates = properties.value(forKey: "dates") as? NSArray {
                                            
                                            if let date = dates.value(forKey: "date") as? NSArray {
                                                
                                                let x = date[dateCounter] as! NSArray
                                                let y = x.count - 1
                                                self.pinSubTitle = "Latest update: \(x[y])"
                                                dateCounter += 1
                                                
                                            }
                                            if let maxBlight = dates.value(forKey: "max_blight") as? NSArray {
                                                
                                                
                                                let x = maxBlight[maxBlightCounter] as! NSArray
                                                let y = x.count - 1
                                                
                                                let z = x[y] as! Double * 100
                                                let v = Double(round(100*z)/100)
                                                self.pinTitle = "\(v) %"
                                                maxBlightCounter += 1
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    self.ownPin = OwnPin()
                                    self.ownPin.title = self.pinTitle
                                    self.ownPin.subtitle = self.pinSubTitle
                                    self.ownPin.coordinate = CLLocationCoordinate2D(latitude: self.pinLat, longitude: self.pinLng)
                                    self.ownPin.color = self.pinColor
                                    self.mainMapView.addAnnotation(self.ownPin)
                                }
                                
                            }
//                            if let type = jsonObj!.value(forKey:"type") as? String {
//                                print("type: ", type)
//                            }
                            
                        }
                        
                    } catch {
                        
                    }
                }
                
            }}.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPins()
    }
    
    
    @IBAction func centerMap(_ sender: UIButton) {
        zoomInUserLocation()
    }
    
    
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Map -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        localtion_lat = userLocation.coordinate.latitude
        location_long = userLocation.coordinate.longitude
    }
    
    func moveMap() {
        let initialLocation = CLLocation(latitude: localtion_lat, longitude: location_long) //correct, replase to this when live
        let regionRadius: CLLocationDistance = 90000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mainMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func zoomInUserLocation () {
        let initialLocation = CLLocation(latitude: localtion_lat, longitude: location_long) //correct, replase to this when live
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mainMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? OwnPin else { return nil }

        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.isEnabled = true
            view.calloutOffset = CGPoint(x: 0, y: 5)
            let btn = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = btn
        }
        
        
        
        view.animatesWhenAdded = true
        view.clusteringIdentifier = nil
        view.displayPriority = .required
        view.markerTintColor = UIColor(hexString: "\(annotation.color)ff")
        view.glyphImage = UIImage(named: "alarm")
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let clickedAnnotation = view.annotation as! OwnPin
        if clickedAnnotation.title != nil && clickedAnnotation.subtitle != nil && clickedAnnotation.coordinate != nil{
            
            let title = clickedAnnotation.title!
            let subtitle = clickedAnnotation.subtitle!
            let coords = clickedAnnotation.coordinate
            
            let ac = UIAlertController(title: "\(title) risk of infection", message: "\(subtitle) \n\nCoords:\nLatitude: \(coords.latitude)\n Longitued: \(coords.longitude)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        
        
    }

}

extension Notification.Name {
    static let updateMap = Notification.Name("updateMap")
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

