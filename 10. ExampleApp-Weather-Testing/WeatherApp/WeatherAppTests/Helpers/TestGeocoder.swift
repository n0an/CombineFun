//
//  TestGeocoder.swift
//  WeatherAppTests
//
//  Created by Ben Scheirman on 12/16/20.
//

import Foundation
import CoreLocation
import Combine
import WeatherKit

class TestGeocoder: Geocoder {
    var subject = PassthroughSubject<[CLPlacemark], Error>()
    func geocodeAddress(address: String) -> AnyPublisher<[CLPlacemark], Error> {
        subject.eraseToAnyPublisher()
    }
}
