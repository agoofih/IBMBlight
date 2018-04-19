//
//  TopWeatherDataVC.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-10.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit
import CoreLocation

class TopWeatherDataVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var degreeCel: UILabel!
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var windDirectionArrow: UIImageView!
    
    var piSixteensths = 0.39269908169
    
    //Own weather API
    var forecastData = [WeatherServer]()
    
    //Live code for location instead of dummy
    let locationManager = CLLocationManager()
    var location : CLLocation?
    var locLat : String = ""
    var locLng : String = ""
    var jsonUrlString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Live code for location instead of dummy
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        ////Live code for location instead of dummy, Use below instead for ownPin in forcast.
        location = locations[0]
        locLat = "\(location!.coordinate.latitude)"
        locLng = "\(location!.coordinate.longitude)"
        jsonUrlString = "https://blighttoaster.eu-gb.mybluemix.net/api/current_weather?lat=\(locLat)&lng=\(locLng)"
        manager.stopUpdatingLocation()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        updateWeatherForLocation(location: "New York")
    }
    
    
    func updateWeatherForLocation (location:String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    let ownPin = OwnPin()
                    ownPin.coordinate = CLLocationCoordinate2D(latitude: 55.606118, longitude: 13.197447)
                    
                    WeatherServer.forecast(withLocation: ownPin.coordinate, completion: { (results:[WeatherServer]?) in
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            if UserDefaults.standard.value(forKey: "weatherDegree") != nil {
                                DispatchQueue.main.async {
                                    self.degreeCel.text = "\(UserDefaults.standard.value(forKey: "weatherDegree")!) °C"
                                }
                                
                            }else{
                                self.degreeCel.text = "- no data -"
                            }
                            if UserDefaults.standard.value(forKey: "weatherWindSpeed") != nil {
                                DispatchQueue.main.async {
                                    let x = UserDefaults.standard.value(forKey: "weatherWindSpeed")! as! Double
                                    let y = Double(round(1000*x)/1000)
                                    self.windSpeed.text = "\(y) m/s"
                                }
                                
                            } else {
                                self.windSpeed.text = "- no data -"
                            }
                            if UserDefaults.standard.value(forKey: "humidity") != nil {
                                DispatchQueue.main.async {
                                    self.humidity.text = "\(UserDefaults.standard.value(forKey: "humidity")!) %"
                                }
                                
                            } else {
                                self.humidity.text = "- no data -"
                            }
                            
                            if UserDefaults.standard.value(forKey: "weatherWindDirection") != nil {
                                DispatchQueue.main.async {
                                    let t = UserDefaults.standard.value(forKey: "weatherWindDirection") as! Int
                                    switch t {
                                    case 0 ... 11:
                                        self.windDirection.text = "Bearing : N"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 8))
                                        }, completion: nil)
                                    case 11 ... 34:
                                        self.windDirection.text = "Bearing : NNE"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 9))
                                        }, completion: nil)
                                    case 34 ... 56:
                                        self.windDirection.text = "Bearing : NE"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 10))
                                        }, completion: nil)
                                    case 56 ... 79:
                                        self.windDirection.text = "Bearing : ENE"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 11))
                                        }, completion: nil)
                                    case 79 ... 101:
                                        self.windDirection.text = "Bearing : E"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 12))
                                        }, completion: nil)
                                    case 101 ... 124:
                                        self.windDirection.text = "Bearing : ESE"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 13))
                                        }, completion: nil)
                                    case 124 ... 146:
                                        self.windDirection.text = "Bearing : SE"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 14))
                                        }, completion: nil)
                                    case 146 ... 169:
                                        self.windDirection.text = "Bearing : SSE"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 15))
                                        }, completion: nil)
                                    case 169 ... 191:
                                        self.windDirection.text = "Bearing : S"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 16))
                                        }, completion: nil)
                                        
                                    case 191 ... 214:
                                        self.windDirection.text = "Bearing : SSW"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 1))
                                        }, completion: nil)
                                    case 214 ... 236:
                                        self.windDirection.text = "Bearing : SW"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 2))
                                        }, completion: nil)
                                    case 236 ... 259:
                                        self.windDirection.text = "Bearing : WSW"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 3))
                                        }, completion: nil)
                                    case 259 ... 281:
                                        self.windDirection.text = "Bearing : W"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 4))
                                        }, completion: nil)
                                    case 281 ... 304:
                                        self.windDirection.text = "Bearing : WNW"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 5))
                                        }, completion: nil)
                                    case 304 ... 326:
                                        self.windDirection.text = "Bearing : NW"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 6))
                                        }, completion: nil)
                                    case 326 ... 349:
                                        self.windDirection.text = "Bearing : NNW"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 7))
                                        }, completion: nil)
                                    case 349 ... 360:
                                        self.windDirection.text = "Bearing : N"
                                        self.windDirectionArrow.transform = CGAffineTransform.identity
                                        UIView.animate(withDuration: 1, animations: {
                                            self.windDirectionArrow.transform = CGAffineTransform(rotationAngle: CGFloat(self.piSixteensths * 8))
                                        }, completion: nil)
                                    default:
                                        print("failure")
                                        print("The wind bearing is BULLSHIT)")
                                    }
                                    //self.windDirectionLabel.text = "\(UserDefaults.standard.value(forKey: "weatherWindDirection")!) heading"
                                }
                                
                            } else {
                                self.windDirection.text = "- no data -"
                            }
                            
                        }
                        
                    })
                }
            }else{
                print(error.debugDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

