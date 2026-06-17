//
//  ValidationService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 15.04.26.
//

import Foundation

struct RegistrationValidationResult: Equatable {
    let nameError: ValidationError.NameError?
    let emailError: ValidationError.EmailError?
    let passwordError: ValidationError.PasswordError?
    let confirmPasswordError: ValidationError.PasswordError?
    
    var isValid: Bool {
        nameError == nil && emailError == nil &&
        passwordError == nil && confirmPasswordError == nil
    }
}

struct LoginValidationResult: Equatable {
    let emailError: ValidationError.EmailError?
    let passwordError: ValidationError.PasswordError?
    
    var isValid: Bool {
        emailError == nil && passwordError == nil
    }
}

protocol ValidationServiceProtocol {
    func validateRegister(registerForm: SignUpModel) -> RegistrationValidationResult
    func validateLogin(loginForm: SignInModel) -> LoginValidationResult
    func validateEmail(_ email: String) -> ValidationError.EmailError?
}


final class ValidationService: ValidationServiceProtocol {
    
    private let MIN_NAME_LENGTH = 3
    private let MIN_PASSWORD_LENGTH = 8
    private let MAX_FIELD_LENGTH = 30
    
    func validateLogin(loginForm: SignInModel) -> LoginValidationResult {
        LoginValidationResult(
            emailError: validateEmail(loginForm.email),
            passwordError: validatePassword(loginForm.password)
        )
    }
    
    func validateRegister(registerForm: SignUpModel) -> RegistrationValidationResult {
        RegistrationValidationResult(
            nameError: validateName(registerForm.name),
            emailError: validateEmail(registerForm.email),
            passwordError: validatePassword(registerForm.password),
            confirmPasswordError: validateConfirmPassword(
                password: registerForm.password,
                confirmPassword: registerForm.confirmPassword
            )
        )
    }
    
    private func validateConfirmPassword(password: String, confirmPassword: String) -> ValidationError.PasswordError? {
        if let error = validatePassword(confirmPassword) {
            return error
        }
        if let error = validatePasswordMismatch(firstPassword: password, secondPassword: confirmPassword) {
            return error
        }
        return nil
    }
    
    private func validatePasswordMismatch(firstPassword: String, secondPassword: String) -> ValidationError.PasswordError? {
        firstPassword == secondPassword ? nil : .passwordMismatch
    }
    
    private func validatePassword(_ password: String) -> ValidationError.PasswordError? {
        if password.isEmpty {
            return .empty
        }
        
        if password.count < MIN_PASSWORD_LENGTH {
            return .tooShort
        }
        
        if password.count > MAX_FIELD_LENGTH {
            return .tooLong
        }
        
        return nil
    }
    
    func validateEmail(_ email: String) -> ValidationError.EmailError? {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if email.isEmpty {
            return .empty
        }
        
        if email.count > MAX_FIELD_LENGTH {
            return .tooLong
        }
        
        if !emailPred.evaluate(with: email) {
            return .invalidFormat
        }
        
        return nil
        
    }
    
    private func validateName(_ name: String) -> ValidationError.NameError? {
        if name.isEmpty {
            return .empty
        }
        
        if name.count < MIN_NAME_LENGTH {
            return .tooShort
        }
        if name.count > MAX_FIELD_LENGTH {
            return .tooLong
        }
        
        return nil
    }
}

extension RegistrationValidationResult {
    init() {
        self.nameError = nil
        self.emailError = nil
        self.passwordError = nil
        self.confirmPasswordError = nil
    }
}

extension LoginValidationResult {
    init() {
        self.emailError = nil
        self.passwordError = nil
    }
}
