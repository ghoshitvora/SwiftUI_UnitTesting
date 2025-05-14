//
//  HomeViewModel.swift
//  SwiftUI_TestCase
//
//  Created by Ghoshit.
//

import Foundation
import Combine

protocol UserServiceProtocol {
    func fetchUsers() -> AnyPublisher<[HomeModel], Error>
}

class HomeViewModel: ObservableObject {
    @Published var users: [HomeModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func getUsers() {
        isLoading = true
        errorMessage = nil
        
        userService.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { users in
                self.users = users
            })
            .store(in: &self.cancellables)
    }
    
}
