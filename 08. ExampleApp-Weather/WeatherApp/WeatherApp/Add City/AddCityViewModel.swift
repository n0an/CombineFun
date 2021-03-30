//
//  AddCityViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import UIKit
import Combine
import WeatherKit
import MapKit
import CoreLocation

class AddCityViewModel: NSObject {
    enum Errors: Error {
        case geolocationFailed
    }
    
    private var completionsSubject = CurrentValueSubject<[MKLocalSearchCompletion], Never>([])
    
    @Published
    var results: [AddCityViewController.Result] = []
    
    @Published
    var showSpinner: Bool = false
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        completionsSubject.map { completions in
            completions
                .filter { $0.title.contains(",") }
                .map { AddCityViewController.Result(title: $0.title, subtitle: $0.subtitle)}
        }
        .assign(to: &$results)
            
        searchCompleter.delegate = self
    }
    
    var searchTerm: String? {
        didSet {
            searchCompleter.queryFragment = searchTerm ?? ""
        }
    }
    
    var snapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<AddCityViewController.Section, AddCityViewController.Result>, Never> {
        $results
            .map { results in
                var snapshot = NSDiffableDataSourceSnapshot<AddCityViewController.Section, AddCityViewController.Result>()
                snapshot.appendSections([.results])
                snapshot.appendItems(results)
                return snapshot
            }
            .eraseToAnyPublisher()
    }
    
    func geolocate(selectedIndex index: Int) -> AnyPublisher<City, Error> {
        assert(index < results.count)
        let result = results[index]
        showSpinner = true
        geocoder.cancelGeocode()

        return Future { promise in
            self.geocoder.geocodeAddressString(result.title) { (placemarks, error) in
                assert(Thread.isMainThread)
                self.showSpinner = false
                if let placemark = placemarks?.first {
                    promise(.success(placemark))
                } else {
                    promise(.failure(Errors.geolocationFailed))
                }
            }
        }
        .map { (placemark: CLPlacemark) -> City in
            City(
                name: placemark.name ?? placemark.locality ?? "(unknown city)",
                locality: placemark.administrativeArea ?? placemark.country ?? "",
                latitude: placemark.location?.coordinate.latitude ?? 0,
                longitude: placemark.location?.coordinate.longitude ?? 0)
        }
        .eraseToAnyPublisher()
    }
}

extension AddCityViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completionsSubject.send(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error)")
    }
}
