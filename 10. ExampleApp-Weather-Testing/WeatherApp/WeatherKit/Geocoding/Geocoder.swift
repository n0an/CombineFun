//
//  Geocoder.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 12/16/20.
//

import Foundation
import CoreLocation
import Combine

public protocol Geocoder {
    func geocodeAddress(address: String) -> AnyPublisher<[CLPlacemark], Error>
}
