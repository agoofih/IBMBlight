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
    let humidity : Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        guard let bearing = json["windBearing"] as? Int else {throw SerializationError.missing("windBearing is missing")}
        guard let speed = json["windSpeed"] as? Int else {throw SerializationError.missing("windSpeed is missing")}
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        guard let humidity = json["humidity"] as? Double else {throw SerializationError.missing("humidity is missing")}
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        self.windBearing = bearing
        self.windSpeed = speed
        self.humidity = humidity
        
    }
    
    static let basePath = "https://api.darksky.net/forecast/a6c9c6e1f763444d051c57cf36f360dc/"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        let url = basePath + "\(location.latitude),\(location.longitude)?units=auto"
        print(url)
        
        
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
            
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["currently"] as? [String:Any] {
                            
                            let array = ["poop"]
                            for dataPoint in array {
                                print(dailyForecasts)
                                
                                UserDefaults.standard.set(dailyForecasts["windBearing"]!, forKey: "weatherWindDirection")
                                UserDefaults.standard.set(dailyForecasts["windSpeed"]!, forKey: "weatherWindSpeed")
                                UserDefaults.standard.set(dailyForecasts["temperature"]!, forKey: "weatherDegree")
                                
                                let humidityCalc = dailyForecasts["humidity"] as! Double
                                let humidityRes = humidityCalc * 100
                                UserDefaults.standard.set(humidityRes, forKey: "humidity")
                                
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
