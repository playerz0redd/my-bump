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
    func findUsers(withName name: String) async throws(SocialManagerError) -> [UserDTO]
    func changeFriendStatus(dto: ChangeFriendStatusDTO, newStatus: FriendStatus) async throws(SocialManagerError)
    func fetchUsersByStatus(id: String, status: FriendStatus) async throws(SocialManagerError) -> [FriendDTO]
    func removeRelation(userFromId: String, userToId: String) async throws(SocialManagerError)
    func observeUsersWithStatus(id: String) -> AnyPublisher<[FriendDTO], Never>
    func updateAvatarForFriends(userId: String, newAvatar: String) async throws
}

final class SocialManager: SocialManagerProtocol {
    
    private let database = Firestore.firestore()
    private let userSubject = PassthroughSubject<[FriendDTO], Never>()
    private var userHandler: ListenerRegistration?
    
    func findUsers(withName name: String) async throws(SocialManagerError) -> [UserDTO] {
        do {
            let snapshot = try await database
                .collection(DatabaseCollection.users.rawValue)
                .whereField(DatabaseField.name.rawValue, isGreaterThanOrEqualTo: name)
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
                .collection(DatabaseCollection.social.rawValue)
                .document(id)
                .collection(DatabaseCollection.relations.rawValue)
                .whereField(DatabaseField.status.rawValue, isEqualTo: status.rawValue)
                .getDocuments()
                
            let users = snapshot.documents.compactMap { document in
                try? document.data(as: FriendDTO.self)
            }
    
            return users
        } catch let error {
            throw .fetchError(error)
        }
    }
    
    func updateImageForFriends(userId: String, imagePath: String) async throws {
        do {
            let snapshot = try await database
                .collection(DatabaseCollection.social.rawValue)
                .whereField(FieldPath.documentID(), isNotEqualTo: userId)
                .getDocuments()
            
            let batch = database.batch()
            
        }
    }
    
    func observeUsersWithStatus(id: String) -> AnyPublisher<[FriendDTO], Never> {
        guard userHandler == nil else { return userSubject.eraseToAnyPublisher() }
        
        userHandler = database
            .collection(DatabaseCollection.social.rawValue)
            .document(id)
            .collection(DatabaseCollection.relations.rawValue)
            .addSnapshotListener({ [weak self] snapshotQuery, error in
                guard let snapshot = snapshotQuery?.documents else { return }
                
                let users = snapshot.compactMap { document in
                    try? document.data(as: FriendDTO.self)
                }
                
                self?.userSubject.send(users)
            })
        
        return userSubject.eraseToAnyPublisher()
    }
    
    func updateAvatarForFriends(userId: String, newAvatar: String) async throws {
        do {
            let snapshot = try await database.collectionGroup(DatabaseCollection.relations.rawValue)
                .whereField(FriendStatusField.ownerId.rawValue, isNotEqualTo: userId)
                .getDocuments()
            
            let batch = database.batch()
            
            snapshot.documents.forEach { document in
                let docRef = document.reference
                let updateData: [String: String] = [FriendStatusField.avatarPath.rawValue: newAvatar]
                batch.updateData(updateData, forDocument: docRef)
            }
            
            try await batch.commit()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func removeRelation(userFromId: String, userToId: String) async throws(SocialManagerError) {
        let batch = database.batch()
        
        let myRecord = database.collection(DatabaseCollection.social.rawValue)
            .document(userFromId)
            .collection(DatabaseCollection.relations.rawValue)
            .document(userToId)
        
        let friendRecord = database.collection(DatabaseCollection.social.rawValue)
            .document(userToId)
            .collection(DatabaseCollection.relations.rawValue)
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
            .collection(DatabaseCollection.social.rawValue)
            .document(dto.userFrom.id)
            .collection(DatabaseCollection.relations.rawValue)
            .document(dto.userTo.id)
        
        let friendRecord = database
            .collection(DatabaseCollection.social.rawValue)
            .document(dto.userTo.id)
            .collection(DatabaseCollection.relations.rawValue)
            .document(dto.userFrom.id)
        
        batch.setData([
            FriendStatusField.status.rawValue: newStatus.rawValue,
            FriendStatusField.friendName.rawValue: dto.userTo.name,
            FriendStatusField.timestamp.rawValue: FieldValue.serverTimestamp(),
            FriendStatusField.avatarPath.rawValue: dto.userTo.avatar,
            FriendStatusField.ownerId.rawValue: dto.userFrom.id
        ], forDocument: myRecord)
        
        batch.setData([
            FriendStatusField.status.rawValue: newStatus == .requesting ? FriendStatus.responsing.rawValue : newStatus.rawValue,
            FriendStatusField.friendName.rawValue: dto.userFrom.name,
            FriendStatusField.timestamp.rawValue: FieldValue.serverTimestamp(),
            FriendStatusField.avatarPath.rawValue: dto.userFrom.avatar,
            FriendStatusField.ownerId.rawValue: dto.userTo.id
        ], forDocument: friendRecord)
        
        do {
            try await batch.commit()
        } catch let error {
            throw .saveError(error)
        }
    }
}

private extension SocialManager {
    enum DatabaseField: String {
        case name = "name"
        case status = "status"
    }
}

private extension SocialManager {
    enum DatabaseCollection: String {
        case social = "social"
        case relations = "relations"
        case users = "users"
    }
}

private extension SocialManager {
    enum FriendStatusField: String {
        case status = "status"
        case friendName = "friendName"
        case timestamp = "timestamp"
        case avatarPath = "avatarPath"
        case ownerId = "ownerId"
    }
}
