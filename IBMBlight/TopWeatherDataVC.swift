//
//  TopWeatherDataVC.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-10.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit
import CoreLocation

class TopWeatherDataVC: UIViewController {
    
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var degreeCel: UILabel!
    
    //Weather data Dark Sky API
    var forecastData = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                    
                    Weather.forecast(withLocation: ownPin.coordinate, completion: { (results:[Weather]?) in
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            if UserDefaults.standard.value(forKey: "weatherDegree") != nil {
                                DispatchQueue.main.async {
                                    self.degreeCel.text = "\(UserDefaults.standard.value(forKey: "weatherDegree")!) °C"
                                }
                                
                            }
                            if UserDefaults.standard.value(forKey: "weatherWindSpeed") != nil {
                                DispatchQueue.main.async {
                                    let x = UserDefaults.standard.value(forKey: "weatherWindSpeed")! as! Double
                                    let y = Double(round(1000*x)/1000)
                                    self.windSpeed.text = "\(y) m/s"
                                }
                                
                            }
                            if UserDefaults.standard.value(forKey: "weatherWindDirection") != nil {
                                DispatchQueue.main.async {
                                    let t = UserDefaults.standard.value(forKey: "weatherWindDirection") as! Int
                                    switch t {
                                    case 0 ... 11:
                                        self.windDirection.text = "Bearing : N"
                                    case 11 ... 34:
                                        self.windDirection.text = "Bearing : NNE"
                                    case 34 ... 56:
                                        self.windDirection.text = "Bearing : NE"
                                    case 56 ... 79:
                                        self.windDirection.text = "Bearing : ENE"
                                    case 79 ... 101:
                                        self.windDirection.text = "Bearing : E"
                                    case 101 ... 124:
                                        self.windDirection.text = "Bearing : ESE"
                                    case 124 ... 146:
                                        self.windDirection.text = "Bearing : SE"
                                    case 146 ... 169:
                                        self.windDirection.text = "Bearing : SSE"
                                    case 169 ... 191:
                                        self.windDirection.text = "Bearing : S"
                                    case 191 ... 214:
                                        self.windDirection.text = "Bearing : SSW"
                                    case 214 ... 236:
                                        self.windDirection.text = "Bearing : SW"
                                    case 236 ... 259:
                                        self.windDirection.text = "Bearing : WSW"
                                    case 259 ... 281:
                                        self.windDirection.text = "Bearing : W"
                                    case 281 ... 304:
                                        self.windDirection.text = "Bearing : WNW"
                                    case 304 ... 326:
                                        self.windDirection.text = "Bearing : NW"
                                    case 326 ... 349:
                                        self.windDirection.text = "Bearing : NNW"
                                    case 349 ... 360:
                                        self.windDirection.text = "Bearing : N"
                                    default:
                                        print("failure")
                                        print("The wind bearing is BULLSHIT)")
                                    }
                                    //self.windDirectionLabel.text = "\(UserDefaults.standard.value(forKey: "weatherWindDirection")!) heading"
                                }
                                
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
