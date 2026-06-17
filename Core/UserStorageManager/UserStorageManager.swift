//
//  UserStorageManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 29.04.26.
//

import Foundation
import FirebaseFirestore

protocol UserStorageManagerProtocol {
    func createUserProfile(name: String?, email: String?, id: String) async throws(UserStorageError)
    func addUserAvatar(forUserId: String, avatarId: String) async throws(UserStorageError)
    func getUserAvatarPath(forUserId id: String) async throws(UserStorageError) -> String?
    func getUser(with id: String) async -> UserDTO?
}

final class UserStorageManager: UserStorageManagerProtocol {
    
    private let database = Firestore.firestore()
    
    func getUser(with id: String) async -> UserDTO? {
        try? await database.collection(FirestoreCollections.users.rawValue).document(id).getDocument(as: UserDTO.self)
    }
    
    func createUserProfile(name: String?, email: String?, id: String) async throws(UserStorageError) {
        let data: [String: Any] = [
            FirestoreFields.UserFields.id.rawValue: id,
            FirestoreFields.UserFields.name.rawValue: name,
            FirestoreFields.UserFields.email.rawValue: email,
            FirestoreFields.UserFields.createdAt.rawValue: FieldValue.serverTimestamp()
        ]
        do {
            try await database.collection(FirestoreCollections.users.rawValue).document(id).setData(data)
        } catch let error {
            throw castFirestoreError(error)
        }
    }
    
    func getUserAvatarPath(forUserId id: String) async throws(UserStorageError) -> String? {
        do {
            let document = try await database.collection(FirestoreCollections.users.rawValue).document(id).getDocument()
            return document.get(FirestoreFields.UserFields.avatarId.rawValue) as? String
        } catch let error {
            throw castFirestoreError(error)
        }
    }
    
    func addUserAvatar(forUserId id: String, avatarId: String) async throws(UserStorageError) {
        let data: [String: Any] = [FirestoreFields.UserFields.avatarId.rawValue: avatarId]
        do {
            try await database.collection(FirestoreCollections.users.rawValue).document(id).updateData(data)
        } catch let error {
            throw castFirestoreError(error)
        }
    }
    
    private func castFirestoreError(_ error: Error) -> UserStorageError {
        let nsError = error as NSError
        
        guard nsError.domain == FirestoreErrorDomain else { return .unknown(error) }
        
        let code = FirestoreErrorCode(_nsError: nsError).code
        
        switch code {
        case .permissionDenied:
            return .permissionDenied
        case .unavailable:
            return .networkError(error)
        default:
            return .unknown(error)
        }
    }
}
