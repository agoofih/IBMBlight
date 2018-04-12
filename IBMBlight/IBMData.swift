//
//  Weather.swift
//  JSON
//
//  Created by Brian Advent on 11.05.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import Foundation
import CoreLocation


struct IBMData {
    
    let urlString = "http://jsonplaceholder.typicode.com/users/1"
    guard let requestUrl = URL(string:urlString) else { return }
    let request = URLRequest(url:requestUrl)
    let task = URLSession.shared.dataTask(with: request) {
        (data, response, error) in
        if error == nil,let usableData = data {
            print(usableData) //JSONSerialization
        }
    }
}
task.resume()
}
