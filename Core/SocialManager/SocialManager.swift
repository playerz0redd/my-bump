//
//  SocialManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol SocialManagerProtocol {
    func findUsers(with name: String) async throws(SocialManagerError) -> [UserDTO]
    func changeFriendStatus(dto: ChangeFriendStatusDTO, newStatus: FriendStatus) async throws(SocialManagerError)
    func fetchUsersByStatus(id: String, status: FriendStatus) async throws(SocialManagerError) -> [FriendDTO]
    func removeRelation(userFromId: String, userToId: String) async throws(SocialManagerError)
    func observeUsersWithStatus(id: String) -> AnyPublisher<[FriendDTO], Never>
    func updateAvatarForFriends(userId: String, newAvatar: String) async throws(SocialManagerError)
}

final class SocialManager: SocialManagerProtocol {
    
    private let database = Firestore.firestore()
    private let userSubject = PassthroughSubject<[FriendDTO], Never>()
    private var userHandler: ListenerRegistration?
    
    func findUsers(with name: String) async throws(SocialManagerError) -> [UserDTO] {
        do {
            let snapshot = try await database
                .collection(FirestoreCollections.users.rawValue)
                .whereField(FirestoreFields.UserFields.name.rawValue, isGreaterThanOrEqualTo: name)
                .getDocuments()
            
            let users = snapshot.documents.compactMap { document in
                try? document.data(as: UserDTO.self)
            }
            
            return users
        } catch let error {
            throw .fetchError(error)
        }
    }
    
    func fetchUsersByStatus(id: String, status: FriendStatus) async throws(SocialManagerError) -> [FriendDTO] {
        do {
            let snapshot = try await database
                .collection(FirestoreCollections.social.rawValue)
                .document(id)
                .collection(FirestoreCollections.relations.rawValue)
                .whereField(FirestoreFields.FriendStatusField.status.rawValue, isEqualTo: status.rawValue)
                .getDocuments()
                
            let users = snapshot.documents.compactMap { document in
                try? document.data(as: FriendDTO.self)
            }
    
            return users
        } catch let error {
            throw .fetchError(error)
        }
    }
    
    func observeUsersWithStatus(id: String) -> AnyPublisher<[FriendDTO], Never> {
        guard userHandler == nil else { return userSubject.eraseToAnyPublisher() }
        
        userHandler = database
            .collection(FirestoreCollections.social.rawValue)
            .document(id)
            .collection(FirestoreCollections.relations.rawValue)
            .addSnapshotListener({ [weak self] snapshotQuery, error in
                guard let snapshot = snapshotQuery?.documents else { return }
                
                let users = snapshot.compactMap { document in
                    try? document.data(as: FriendDTO.self)
                }
                
                self?.userSubject.send(users)
            })
        
        return userSubject.eraseToAnyPublisher()
    }
    
    func updateAvatarForFriends(userId: String, newAvatar: String) async throws(SocialManagerError) {
        do {
            let snapshot = try await database.collectionGroup(FirestoreCollections.relations.rawValue)
                .whereField(FirestoreFields.FriendStatusField.ownerId.rawValue, isNotEqualTo: userId)
                .getDocuments()
            
            let batch = database.batch()
            
            snapshot.documents.forEach { document in
                let docRef = document.reference
                let updateData: [String: String] = [FirestoreFields.FriendStatusField.avatarPath.rawValue: newAvatar]
                batch.updateData(updateData, forDocument: docRef)
            }
            
            try await batch.commit()
        } catch {
            throw SocialManagerError.updateError(error)
        }
    }
    
    func removeRelation(userFromId: String, userToId: String) async throws(SocialManagerError) {
        let batch = database.batch()
        
        let myRecord = database.collection(FirestoreCollections.social.rawValue)
            .document(userFromId)
            .collection(FirestoreCollections.relations.rawValue)
            .document(userToId)
        
        let friendRecord = database.collection(FirestoreCollections.social.rawValue)
            .document(userToId)
            .collection(FirestoreCollections.relations.rawValue)
            .document(userFromId)
        
        batch.deleteDocument(myRecord)
        batch.deleteDocument(friendRecord)
        
        do {
            try await batch.commit()
        } catch let error {
            throw .deleteError(error)
        }
    }
    
    func changeFriendStatus(dto: ChangeFriendStatusDTO, newStatus: FriendStatus) async throws(SocialManagerError) {
        let batch = database.batch()
        
        let myRecord = database
            .collection(FirestoreCollections.social.rawValue)
            .document(dto.userFrom.id)
            .collection(FirestoreCollections.relations.rawValue)
            .document(dto.userTo.id)
        
        let friendRecord = database
            .collection(FirestoreCollections.social.rawValue)
            .document(dto.userTo.id)
            .collection(FirestoreCollections.relations.rawValue)
            .document(dto.userFrom.id)
        
        batch.setData([
            FirestoreFields.FriendStatusField.status.rawValue: newStatus.rawValue,
            FirestoreFields.FriendStatusField.friendName.rawValue: dto.userTo.name,
            FirestoreFields.FriendStatusField.timestamp.rawValue: FieldValue.serverTimestamp(),
            FirestoreFields.FriendStatusField.avatarPath.rawValue: dto.userTo.avatar,
            FirestoreFields.FriendStatusField.ownerId.rawValue: dto.userFrom.id
        ], forDocument: myRecord)
        
        batch.setData([
            FirestoreFields.FriendStatusField.status.rawValue: newStatus == .requesting ? FriendStatus.responsing.rawValue : newStatus.rawValue,
            FirestoreFields.FriendStatusField.friendName.rawValue: dto.userFrom.name,
            FirestoreFields.FriendStatusField.timestamp.rawValue: FieldValue.serverTimestamp(),
            FirestoreFields.FriendStatusField.avatarPath.rawValue: dto.userFrom.avatar,
            FirestoreFields.FriendStatusField.ownerId.rawValue: dto.userTo.id
        ], forDocument: friendRecord)
        
        do {
            try await batch.commit()
        } catch let error {
            throw .saveError(error)
        }
    }
}


