//
//  Weather.swift
//  JSON
//
//  Created by Brian Advent on 11.05.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather {
    let summary:String
    let icon:String
    let temperature:Double
    let windBearing : Int
    let windSpeed : Int
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let Bearing = json["windBearing"] as? Int else {throw SerializationError.missing("windBearing is missing")}
        
        guard let Speed = json["windSpeed"] as? Int else {throw SerializationError.missing("windSpeed is missing")}
        
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        self.windBearing = Bearing
        self.windSpeed = Speed
        
    }
    
    
    static let basePath = "https://api.darksky.net/forecast/a6c9c6e1f763444d051c57cf36f360dc/"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        //print("AD 1")
        
        let url = basePath + "\(location.latitude),\(location.longitude)?units=auto"
        print(url)
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                //print("AD 2")
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        //print("AD 3")
                        if let dailyForecasts = json["currently"] as? [String:Any] {
                            //print("AD 4")
                            
                            let array = ["poop"]
                            for dataPoint in array {
                                print("AD 5")
                                print("Vindens riktining: \(dailyForecasts["windBearing"]!)")
                                print("Vindens styrka: \(dailyForecasts["windSpeed"]!) m/s")
                                print("Temperaturen är: \(dailyForecasts["temperature"]!) celcius")
                                print(".")
                                print(dailyForecasts.description)
//
                                if let weatherObject = try? Weather(json: dailyForecasts) {
                                    print("AD 7")
                                    forecastArray.append(weatherObject)
                                    print("Weather.swift säger att vinrikning är: \(weatherObject.windBearing) och hastighet är: \(weatherObject.windSpeed)")
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
}
