//
//  City+cacheKey.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 11/6/20.
//

import Foundation

public extension City {
    var cacheKey: String {
        String(format: "lat:%.2f|lng:%.2f", latitude, longitude)
    }
}
