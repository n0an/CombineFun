//
//  TestLocalSearch.swift
//  WeatherAppTests
//
//  Created by Ben Scheirman on 12/16/20.
//

import Foundation
import Combine
import WeatherKit

class TestLocalSearch: LocalSearchCompleter {
    var queries: [String] = []
    
    func search(with query: String) {
        queries.append(query)
    }
    
    var subject = PassthroughSubject<[LocalSearchCompletion], Never>()
    
    var results: AnyPublisher<[LocalSearchCompletion], Never> {
        subject.eraseToAnyPublisher()
    }
}
