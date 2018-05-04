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
import GEOSwift

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager!
    
    @IBOutlet weak var mainMapView: MKMapView!
    
    //Base setup, GPS to IBM Malmö
    var localtion_lat = 55.611868
    var location_long = 12.977738
    
    //FakeLocation in CPX File
    //let initialLocation = CLLocation(latitude: 55.606118, longitude: 13.197447)
    //Fake farm 1
    var FF1_lat = 55.598424
    var FF1_long = 13.214542
    
    //Fake farm 2
    var FF2_lat = 55.584106
    var FF2_long = 13.214832
    
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
        
    }
    
    func getPins () {
        let url = URL(string: "https://blighttoaster.eu-gb.mybluemix.net/api/blight_per_point")
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            //            if let response = response {
            //            }
            
            var counter : Int = 0
            var counter2 : Int = 0
            var counter3 : Int = 0
            var counter4 : Int = 0
            
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                            
                            if let features = jsonObj!.value(forKey:"features") as? NSArray {
                                
                                for _ in features{
                                    
                                    
                                    if let geometry = features.value(forKey:"geometry") as? NSArray {
                                        
                                        if let coordinates = geometry.value(forKey:"coordinates") as? NSArray {
                                            
                                            self.pinCoords = coordinates[counter] as! [Double]
                                            counter += 1
                                            
                                            self.pinLng = self.pinCoords[0]
                                            self.pinLat = self.pinCoords[1]
                                            
                                        }
                                    }
                                    if let properties = features.value(forKey:"properties") as? NSArray {
                                        
                                        if let color = properties.value(forKey: "colour") as? [String] {
                                            
                                            self.pinColor = color[counter2] as String
                                            counter2 += 1
                                            
                                        }
                                        
                                        if let dates = properties.value(forKey: "dates") as? NSArray {
                                            
                                            //print("****Detta är dates :", dates)
                                            
                                            if let date = dates.value(forKey: "date") as? NSArray {
                                                
                                                //print("*--*Detta är date :", date)
                                                let abo = date[counter3] as! NSArray
                                                let aboa = abo.count - 1
//                                                print("abo :", abo)
//                                                print("latest date :", abo[aboa])
                                                self.pinSubTitle = "Latest update: \(abo[aboa])"
                                                counter3 += 1
                                                
                                            }
                                            if let maxBlight = dates.value(forKey: "max_blight") as? NSArray {
                                                
                                                //print("----Detta är maxBlight :", maxBlight)
                                                let abo = maxBlight[counter4] as! NSArray
                                                let aboa = abo.count - 1
                                                //                                                print("abo :", abo)
                                                //                                                print("latest date :", abo[aboa])
                                                self.pinTitle = "\(abo[aboa])"
                                                counter4 += 1
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    //print("Rullande: lat = \(self.pinLat), lng = \(self.pinLng), color = \(self.pinColor)")
                                    
                                    self.ownPin = OwnPin()
                                    self.ownPin.title = self.pinTitle
                                    self.ownPin.subtitle = self.pinSubTitle
                                    self.ownPin.coordinate = CLLocationCoordinate2D(latitude: self.pinLat, longitude: self.pinLng)
//                                    self.ownPin.blight = true
                                    self.ownPin.color = self.pinColor
                                    self.mainMapView.addAnnotation(self.ownPin)
                                }
                                
                            }
                            if let type = jsonObj!.value(forKey:"type") as? String {
                                //                                print("type: ", type)
                            }
                            
                        }
                        
                    } catch {
                        
                    }
                }
                
            }}.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPins()
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
        //let initialLocation = CLLocation(latitude: localtion_lat, longitude: location_long) //correct, replase to this when live
        let initialLocation = CLLocation(latitude: 55.606118, longitude: 13.197447) // tempdata GPS
        let regionRadius: CLLocationDistance = 112500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mainMapView.setRegion(coordinateRegion, animated: true)
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if let annotation = annotation as? OwnPin {
//            let identifier = "pin"
//            var view: MKPinAnnotationView
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//                as? MKPinAnnotationView {
//                dequeuedView.annotation = annotation
//                view = dequeuedView
//            } else {
//                // 3
//                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: 5)
//                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
//            }
//            view.pinTintColor = UIColor(hexString: "\(annotation.color)ff")
//
//            return view
//        }
//        return nil
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? OwnPin else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        view.markerTintColor = UIColor(hexString: "\(annotation.color)ff")
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
        
        let clickedAnnotation = view.annotation as! OwnPin
        if clickedAnnotation.title != nil {
            print(clickedAnnotation.title!)
        }
        
    }

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

