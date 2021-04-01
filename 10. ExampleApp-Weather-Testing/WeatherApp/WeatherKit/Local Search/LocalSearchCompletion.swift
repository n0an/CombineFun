//
//  LocalSearchCompletion.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 12/16/20.
//

import Foundation

public struct LocalSearchCompletion: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
