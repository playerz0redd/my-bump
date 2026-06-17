//
//  AuthScreenFactory.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 17.06.26.
//

import Foundation

protocol AuthScreenFactoryProtocol {
    func buildAuthViewModel() -> AuthViewModel
}

final class AuthScreenFactory: AuthScreenFactoryProtocol {
    
    private let authManager: AuthManagerProtocol
    private let userStorageManager: UserStorageManagerProtocol
    private let validationService: ValidationServiceProtocol = ValidationService()
    
    init(authManager: AuthManagerProtocol, userStorageManager: UserStorageManagerProtocol) {
        self.authManager = authManager
        self.userStorageManager = userStorageManager
    }
    
    func buildAuthViewModel() -> AuthViewModel {
        let authService = AuthService(authManager: authManager, userStorageManager: userStorageManager)
        
        return AuthViewModel(dependency: .init(
            authService: authService,
            validationService: validationService)
        )
    }
}
