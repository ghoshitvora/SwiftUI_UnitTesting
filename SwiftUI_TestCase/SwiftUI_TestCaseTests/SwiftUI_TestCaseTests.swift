//
//  SwiftUI_TestCaseTests.swift
//  SwiftUI_TestCaseTests
//
//  Created by Ghoshit.
//

import XCTest
import Combine
@testable import SwiftUI_TestCase

class MockUserService: UserServiceProtocol {
    var shouldReturnError = false
    
    func fetchUsers() -> AnyPublisher<[HomeModel], Error> {
        if shouldReturnError {
            return Fail(error: URLError(.notConnectedToInternet))
                .eraseToAnyPublisher()
        } else {
            let users = [
                HomeModel(id: 1, name: "Alice", email: "alice@test.com"),
                HomeModel(id: 2, name: "Bob", email: "bob@test.com")
            ]
            return Just(users)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

class SwiftUI_TestCaseTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockService: MockUserService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        self.mockService = MockUserService()
        self.viewModel = HomeViewModel(userService: self.mockService)
        cancellables = []
    }
    
    override func tearDown() {
        self.viewModel = nil
        self.mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testGetUsers_Success() {
        let expectation = XCTestExpectation(description: "User should feched")
        
        viewModel.$users
            .dropFirst()
            .sink { users in
                XCTAssertEqual(users.count, 2)
                XCTAssertEqual(users.first?.name, "Alice")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.getUsers()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetUsers_Failure() {
        let expectation = XCTestExpectation(description: "Error should handeled")
        mockService.shouldReturnError = true
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error?.contains("offline") ?? false || error?.contains("Internet") ?? false)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.getUsers()
        wait(for: [expectation], timeout: 2.0)
    }
}
