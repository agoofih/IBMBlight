//
//  OwnPin.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-09.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import Foundation
import MapKit

class OwnPin: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.611461, longitude: 12.9941182)
    var color : String = "#d3d3d3"
}
