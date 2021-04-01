//
//  LocalSearchCompleter.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 12/16/20.
//

import Foundation
import Combine

public protocol LocalSearchCompleter {
    func search(with query: String)
    var results: AnyPublisher<[LocalSearchCompletion], Never> { get }
}
