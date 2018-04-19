//
//  Weather.swift
//  JSON
//
//  Created by Brian Advent on 11.05.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import Foundation
import CoreLocation


struct WeatherServer {
    
    let temperature : Double
    let windBearing : Int
    let windSpeed : Double
    let humidity : Int
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
    
        guard let bearing = json["windBearing"] as? Int else {throw SerializationError.missing("windBearing is missing")}
        guard let speed = json["windSpeed"] as? Double else {throw SerializationError.missing("windSpeed is missing")}
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        guard let humidity = json["humidity"] as? Int else {throw SerializationError.missing("humidity is missing")}
        
        self.temperature = temperature
        self.windBearing = bearing
        self.windSpeed = speed
        self.humidity = humidity
        
    }

    static let basePath = "https://blighttoaster.eu-gb.mybluemix.net/api/current_weather?"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([WeatherServer]?) -> ()) {
        
        
        let url = basePath + "lat=\(location.latitude)&lng=\(location.longitude)"
        print(url)
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            let forecastArray:[WeatherServer] = []
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["current"] as? [String:Any] {
                            let array = ["poop"]
                            for dataPoint in array {
                      
                                UserDefaults.standard.set(dailyForecasts["wd"]!, forKey: "weatherWindDirection")
                                UserDefaults.standard.set(dailyForecasts["ws"]!, forKey: "weatherWindSpeed")
                                UserDefaults.standard.set(dailyForecasts["t"]!, forKey: "weatherDegree")
                                UserDefaults.standard.set(dailyForecasts["r"], forKey: "humidity")
                                
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
