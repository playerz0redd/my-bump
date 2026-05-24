//
//  AuthService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.04.26.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    var signPublisher: AnyPublisher<Bool, Never> { get }
    
    func signUp(name: String, email: String, password: String) async throws(AuthServiceError)
    func signIn(email: String, password: String) async throws(AuthServiceError)
    func signOut() throws(AuthServiceError)
    func changePassword(email: String) async throws(AuthServiceError)
    func signInWithGoogle() async throws(AuthServiceError)
}

final class AuthService: AuthServiceProtocol {
    
    private let authManager: AuthManagerProtocol
    private let userStorageManager: UserStorageManagerProtocol
    
    init(authManager: AuthManagerProtocol, userStorageManager: UserStorageManagerProtocol) {
        self.authManager = authManager
        self.userStorageManager = userStorageManager
    }
    
    var signPublisher: AnyPublisher<Bool, Never> {
        authManager.isSignedPublisher
    }
    
    func signInWithGoogle() async throws(AuthServiceError) {
        do {
            let userInfo = try await authManager.signInWithGoogle()
            try await userStorageManager.createUserProfile(name: userInfo.name, email: userInfo.email, id: userInfo.uid)
        } catch let error as AuthManagerError {
            throw .loginError(error)
        } catch let error as UserStorageError {
            throw .saveProfileError(error)
        } catch let error {
            throw .unknown(error)
        }
    }
    
    func signUp(name: String, email: String, password: String) async throws(AuthServiceError) {
        do {
            let uid = try await authManager.signUp(username: name, email: email, password: password)
            try await userStorageManager.createUserProfile(name: name, email: email, id: uid)
        } catch let error as AuthManagerError {
            throw .registerError(error)
        } catch let error as UserStorageError {
            throw .saveProfileError(error)
        } catch let error {
            throw .unknown(error)
        }
    }
    
    func signIn(email: String, password: String) async throws(AuthServiceError) {
        do {
            try await authManager.signIn(email: email, password: password)
        } catch let error {
            throw .loginError(error)
        }
    }
    
    func signOut() throws(AuthServiceError) {
        do {
            try authManager.signOut()
        } catch let error {
            throw .signOutError(error)
        }
    }
    
    var isSignedIn: Bool {
        authManager.isSignedIn
    }
    
    func changePassword(email: String) async throws(AuthServiceError) {
        do {
            try await authManager.changePassword(email: email)
        } catch let error {
            throw .changePasswordError(error)
        }
    }
}
