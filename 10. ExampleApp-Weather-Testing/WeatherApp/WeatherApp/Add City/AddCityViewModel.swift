//
//  AddCityViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import UIKit
import Combine
import WeatherKit
import CoreLocation

class AddCityViewModel: NSObject {
    enum Errors: Error {
        case geolocationFailed
    }
    
    @Published
    var results: [LocalSearchCompletion] = []
    
    @Published
    var showSpinner: Bool = false
    
    private var localSearch: LocalSearchCompleter { Current.localSearch }
    private var geocoder: Geocoder { Current.geocoder }
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        localSearch.results
            .map { completions in
                completions.filter { $0.title.contains(",") }
            }
            .assign(to: &$results)
    }
    
    var searchTerm: String? {
        didSet {
            localSearch.search(with: searchTerm ?? "")
        }
    }
    
    func geolocate(selectedIndex index: Int) -> AnyPublisher<City, Errors> {
        assert(index < results.count)
        let result = results[index]
        showSpinner = true
        
        return geocoder.geocodeAddress(address: result.title)
            .handleEvents(receiveCompletion: { _ in
                self.showSpinner = false
            })
            .mapError { e in
                print("Geolocation error: \(e)")
                return Errors.geolocationFailed
            }
            .compactMap { $0.first }
            .map { (placemark: CLPlacemark) -> City in
                City(
                    name: placemark.name ?? placemark.locality ?? "(unknown city)",
                    locality: placemark.administrativeArea ?? placemark.country ?? "",
                    latitude: placemark.location?.coordinate.latitude ?? 0,
                    longitude: placemark.location?.coordinate.longitude ?? 0
                )
            }
            .eraseToAnyPublisher()
    }
    
    var snapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<AddCityViewController.Section, LocalSearchCompletion>, Never> {
        $results
            .map { results in
                var snapshot = NSDiffableDataSourceSnapshot<AddCityViewController.Section, LocalSearchCompletion>()
                snapshot.appendSections([.results])
                snapshot.appendItems(results)
                return snapshot
            }
            .eraseToAnyPublisher()
    }
}
