//
//  ChatManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol ChatManagerProtocol {
    func getChatsPublisher(forUser id: String) -> AnyPublisher<[ChatDTO], Never>
    func createChat(userFromId: String, userToId: String) async throws(ChatManagerError)
    func removeChat(chat id: String)
    func fetchChats(forUser id: String) async throws(ChatManagerError) -> [ChatDTO]
}

final class ChatManager: ChatManagerProtocol {
    
    private var chatListener: ListenerRegistration?
    private let chatsSubject = PassthroughSubject<[ChatDTO], Never>()
    private let database = Firestore.firestore()
    
    deinit {
        chatListener?.remove()
    }
    
    func getChatsPublisher(forUser id: String) -> AnyPublisher<[ChatDTO], Never> {
        observeChats(myId: id)
        return chatsSubject
            .eraseToAnyPublisher()
    }
    
    func fetchChats(forUser id: String) async throws(ChatManagerError) -> [ChatDTO] {
        do {
            return try await database
                .collection(FirestoreCollections.chats.rawValue)
                .whereField(FirestoreFields.Chat.members.rawValue, arrayContains: id)
                .getDocuments()
                .documents
                .compactMap { document in
                    try? document.data(as: ChatDTO.self)
                }
        } catch {
            throw .fetchError(error)
        }
    }
    
    func removeChat(chat id: String) {
        database.collection(FirestoreCollections.chats.rawValue).document(id).delete()
    }
    
    func createChat(userFromId: String, userToId: String) async throws(ChatManagerError) {
        let chatModel: [String: Any] = [FirestoreFields.Chat.members.rawValue: [userFromId, userToId]]
        do {
            try await database.collection(FirestoreCollections.chats.rawValue).addDocument(data: chatModel)
        } catch {
            throw .createError(error)
        }
    }
    
    private func observeChats(myId: String) {
        guard chatListener == nil else { return }
        
        chatListener = database
            .collection(FirestoreCollections.chats.rawValue)
            .whereField(FirestoreFields.Chat.members.rawValue, arrayContains: myId)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let chats = snapshot?.documents.compactMap({ try? $0.data(as: ChatDTO.self) }) else { return }
                self?.chatsSubject.send(chats)
            }
    }
}


