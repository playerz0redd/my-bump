//
//  AuthViewModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.04.26.
//

import Foundation
import Observation
import Combine

@Observable @MainActor
final class AuthViewModel {
    
    var authState: AuthState = .login
    
    var registrationForm: SignUpModel = .init()
    var registrationValidationResult: RegistrationValidationResult = .init()
    
    var loginForm: SignInModel = .init()
    var loginValidationResult: LoginValidationResult = .init()
    
    var authError: AuthServiceError?
    
    var resetPasswordEmail: String = ""
    var resetPasswordError: AuthServiceError?
    var resetPasswordEmailError: ValidationError.EmailError?
    
    var isSignedIn: Bool = false
    
    private let authService: AuthServiceProtocol
    private let validationService: ValidationServiceProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(dependency: DependencyContainer) {
        self.authService = dependency.authService
        self.validationService = dependency.validationService
        
        authService.signPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isSignedIn = value
            }
            .store(in: &cancellables)
    }
    
    func register() {
        registrationValidationResult = validationService.validateRegister(registerForm: registrationForm)
        
        guard registrationValidationResult.isValid else { return }
        
        performAuthTask {
            try await self.authService.signUp(
                name: self.registrationForm.name,
                email: self.registrationForm.email,
                password: self.registrationForm.password
            )
        }
    }
    
    func login() {
        loginValidationResult = validationService.validateLogin(loginForm: loginForm)
        
        guard loginValidationResult.isValid else { return }
        
        performAuthTask {
            try await self.authService.signIn(
                email: self.loginForm.email,
                password: self.loginForm.password
            )
        }
    }
    
    func changePassword() {
        resetPasswordEmailError = nil
        resetPasswordEmailError = validationService.validateEmail(resetPasswordEmail)
        
        if let error = validationService.validateEmail(resetPasswordEmail) {
            resetPasswordEmailError = error
            return
        }
        
        performAuthTask {
            try await self.authService.changePassword(email: self.resetPasswordEmail)
            self.authState = .resetPassword(.confirmation)
        }
    }
    
    func googleSignIn() {
        performAuthTask {
            try await self.authService.signInWithGoogle()
        }
    }
    
    func changeAuthState(to type: AuthState) {
        loginValidationResult = LoginValidationResult()
        registrationValidationResult = RegistrationValidationResult()
        resetPasswordEmailError = nil
        eraseAuthError()
        authState = type
    }
    
    func eraseAuthError() {
        authError = nil
    }
    
    func getErrorMessage(for field: FieldType) -> LocalizedStringResource? {
        switch field {
        case .name:
            registrationValidationResult.nameError?.message
        case .email:
            registrationValidationResult.emailError?.message
        case .password:
            registrationValidationResult.passwordError?.message
        case .confirmPassword:
            registrationValidationResult.confirmPasswordError?.message
        }
    }
    
    private func performAuthTask(action: @escaping () async throws -> Void) {
        eraseAuthError()
        Task {
            do {
                try await action()
            } catch let error as AuthServiceError {
                self.authError = error
            }
        }
    }

}

extension AuthViewModel {
    enum AuthState: Equatable {
        case register
        case login
        case resetPassword(ResetPasswordState)
        
        enum ResetPasswordState: Equatable {
            case inputEmail
            case confirmation
        }
    }
}

extension AuthViewModel {
    struct DependencyContainer {
        let authService: AuthServiceProtocol
        let validationService: ValidationServiceProtocol
    }
}
