//
//  CoreLocationGeocoder.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 12/16/20.
//

import Foundation
import CoreLocation
import Combine

public class CoreLocationGeocoder: Geocoder {
    private let geocoder = CLGeocoder()
    
    public init() {
    }
    
    public func geocodeAddress(address: String) -> AnyPublisher<[CLPlacemark], Error> {
        geocoder.cancelGeocode()
        return Future { [self] promise in
            self.geocoder.geocodeAddressString(address) { (placemarks, error) in
                if let placemarks = placemarks {
                    promise(.success(placemarks))
                } else {
                    promise(.failure(error!))
                }
                
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
