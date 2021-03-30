//
//  MyCitiesViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/29/20.
//

import Foundation
import UIKit
import WeatherKit
import Combine

class MyCitiesViewModel {
    enum Section: Int {
        case cities
    }
    
    private let tempFormatter = MeasurementFormatter()
    
    init() {
        tempFormatter.numberFormatter.maximumFractionDigits = 0
    }
    
    private var citiesStore: CitiesStore {
        Current.citiesStore
    }
    
    private var cities: AnyPublisher<[CityViewModel], Never> {
        citiesStore.$cities
            .map { [tempFormatter] cities in
                cities.map { city in
                    CityViewModel(city: city,
                                  weather: Current.weatherManager.weatherPublisher(for: city),
                                  tempFormatter: tempFormatter)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func contextMenu(for index: Int) -> UIMenu {
        let city = citiesStore.cities[index]
        let action = UIAction(title: "Delete City", attributes: [.destructive]) { [weak self] action in
            self?.citiesStore.remove(city)
        }
        
        let menu = UIMenu(title: city.name, options: [], children: [action])
        return menu
    }
    
    var snapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<Section, CityViewModel>, Never> {
        cities.map { cities in
            var snapshot = NSDiffableDataSourceSnapshot<Section, CityViewModel>()
            snapshot.appendSections([.cities])
            snapshot.appendItems(cities)
            return snapshot
        }
        .eraseToAnyPublisher()
    }
}
