//
//  AuthManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.04.26.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import Firebase
import Combine

protocol AuthManagerProtocol {
    var isSignedPublisher: AnyPublisher<Bool, Never> { get }
    var isSignedIn: Bool { get }
    
    func signUp(username: String, email: String, password: String) async throws(AuthManagerError) -> String
    func signIn(email: String, password: String) async throws(AuthManagerError)
    func signOut() throws(AuthManagerError)
    func changePassword(email: String) async throws(AuthManagerError)
    func signInWithGoogle() async throws(AuthManagerError) -> FirebaseAuthManager.UserStorageModel
}

protocol UserSessionProtocol {
    var userId: String? { get }
    var username: String? { get }
    
    func signOut() throws(AuthManagerError)
}

final class FirebaseAuthManager: AuthManagerProtocol, UserSessionProtocol  {
    
    var username: String? {
        Auth.auth().currentUser?.displayName
    }
    
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var isSignedPublisher: AnyPublisher<Bool, Never> {
        signSubject.eraseToAnyPublisher()
    }
    
    var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    private var signSubject = PassthroughSubject<Bool, Never>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        listenToAuthState()
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signUp(username: String, email: String, password: String) async throws(AuthManagerError) -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = username
            
            try await changeRequest.commitChanges()
            
            return result.user.uid
        } catch let error {
            throw castFirebaseError(error)
        }
    }
    
    func signInWithGoogle() async throws(AuthManagerError) -> UserStorageModel {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { throw .emailIsAlreadyInUse }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let topViewController = Utils.getTopViewController() else {
            throw .unknown(NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "UI not ready"]))
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
            
            guard let idToken = result.user.idToken?.tokenString else { throw AuthManagerError.missGoogleIdToken }
            
            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let authResult = try await Auth.auth().signIn(with: credential)
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = result.user.profile?.name
            try await changeRequest.commitChanges()
            
            return UserStorageModel(uid: authResult.user.uid, name: result.user.profile?.name, email: authResult.user.email)
            
        } catch {
            if let googleError = error as? NSError, googleError.code == GIDSignInError.canceled.rawValue {
                 throw .userCancelledSignIn
             }
             
             if let managerError = error as? AuthManagerError {
                 throw managerError
             }
             
             throw castFirebaseError(error)
        }
    }
    
    func signIn(email: String, password: String) async throws(AuthManagerError) {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let error {
            throw castFirebaseError(error)
        }
    }
    
    func signOut() throws(AuthManagerError) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            throw castFirebaseError(error)
        }
    }
    
    func changePassword(email: String) async throws(AuthManagerError) {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error {
            throw castFirebaseError(error)
        }
    }
    
    private func listenToAuthState() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            let isLogged = (user != nil)
            self?.signSubject.send(isLogged)
        }
    }
    
    private func castFirebaseError(_ error: Error) -> AuthManagerError {
        guard let errorCode = AuthErrorCode(rawValue: (error as NSError).code) else { return .unknown(error) }
        
        switch errorCode {
        case .emailAlreadyInUse:
            return .emailIsAlreadyInUse
        case .wrongPassword, .userNotFound, .invalidCredential:
            return .userNotFound
        case .invalidEmail:
            return .invalidEmail(error)
        case .networkError, .tooManyRequests:
            return .networkError(error)
        default:
            return .unknown(error)
        }
    }
}

extension FirebaseAuthManager {
    struct UserStorageModel {
        let uid: String
        let name: String?
        let email: String?
    }
}
