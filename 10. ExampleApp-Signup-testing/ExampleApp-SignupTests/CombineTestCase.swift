//
//  CombineTestCase.swift
//  ExampleApp-SignupTests
//
//  Created by Ben Scheirman on 12/14/20.
//

import Foundation
import Combine
import XCTest

class CombineTestCase: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        cancellables = nil
    }
    
    func assertPublisher<P: Publisher>(_ publisher: P, producesExactly expected: P.Output..., block: () -> Void) where P.Failure == Never, P.Output: Equatable {
        let exp = expectation(description: "Publisher completed")
        exp.assertForOverFulfill = false
        
        // Arrange
        var value: [P.Output] = []
        publisher
            .handleEvents(receiveCompletion: { _ in
                exp.fulfill()
            })
            .sink {
                exp.fulfill()
                value.append($0)
            }
            .store(in: &cancellables)
        
        // Act
        block()
        
        wait(for: [exp], timeout: 1.0)
        
        // Assertion
        XCTAssertEqual(value, expected)
    }
    
    func assertPublisher<P: Publisher>(_ publisher: P, produces expected: P.Output, block: () -> Void) where P.Failure == Never, P.Output: Equatable {
        let exp = expectation(description: "Publisher completed")
        exp.assertForOverFulfill = false
        
        // Arrange
        var value: P.Output?
        publisher
            .handleEvents(receiveCompletion: { _ in
                exp.fulfill()
            })
            .sink {
                exp.fulfill()
                value = $0
            }
            .store(in: &cancellables)
        
        // Act
        block()
        
        wait(for: [exp], timeout: 1.0)
        
        // Assertion
        XCTAssertEqual(value, expected)
    }
}
