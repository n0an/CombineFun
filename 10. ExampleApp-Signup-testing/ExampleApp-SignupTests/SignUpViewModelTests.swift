//
//  SignUpViewModelTests.swift
//  ExampleApp-SignupTests
//
//  Created by Ben Scheirman on 12/14/20.
//

import XCTest
import Combine
@testable import ExampleApp_Signup

// SIGN UP FORM RULES
// - email address must be valid (contain @ and .)
// - password must be at least 8 characters
// - password cannot be "password"
// - password confirmation must match
// - must agree to terms
// - BONUS: color email field red when invalid, password confirmation field red when it doesn't match the password
// - BONUS: email address must remove spaces, lowercased

class SignUpViewModelTests: CombineTestCase {

    var viewModel: SignUpViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SignUpViewModel()
    }
    
    func testValidEmail() {
        assertPublisher(viewModel.validEmailAddress, produces: true) {
            viewModel.email = "foo@bar.com"
        }
    }
    
    func testInvalidEmail() {
        assertPublisher(viewModel.validEmailAddress, produces: false) {
            viewModel.email = "foo"
        }
    }
    
    func testValidPassword() {
        assertPublisher(viewModel.validPassword, produces: true) {
            viewModel.password = "combineswift1"
        }
    }
    
    func testInvalidPassword() {
        assertPublisher(viewModel.validPassword, produces: false) {
            viewModel.password = "combine"
        }
    }
    
    func testPasswordMatchesConfirmation() {
        assertPublisher(viewModel.passwordMatchesConfirmation.dropFirst(2), producesExactly: false, true) {
            viewModel.password = "combineswift1"
            viewModel.passwordConfirmation = "combineswift2" // --> false
            
            viewModel.passwordConfirmation = "combineswift1" // --> true
        }
    }
    
    func testFormIsValid() {
        var isValidSignal: Bool?
        viewModel.formIsValid
            .sink { isValidSignal = $0 }
            .store(in: &cancellables)
        
        viewModel.email = "invalid"
        viewModel.password = "invalid"
        viewModel.passwordConfirmation = "invalid2"
        viewModel.agreeTerms = false
        XCTAssertEqual(isValidSignal, false)
        
        viewModel.email = "tcook@apple.com"
        viewModel.password = "combineswift1"
        viewModel.passwordConfirmation = "combineswift1"
        viewModel.agreeTerms = true
        XCTAssertEqual(isValidSignal, true)
    }
}
