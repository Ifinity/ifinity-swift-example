//
//  VenueAnnotation.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 15.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import Foundation
import MapKit

class VenueAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}