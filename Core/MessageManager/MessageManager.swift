//
//  MessageManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation
import FirebaseFirestore
import Combine

protocol MessageManagerProtocol {
    func observeChat(id: String) -> AnyPublisher<[MessageResponse], Never>
    func sendMessage(message: MessageRequest) async throws(MessageManagerError)
    func fetchMessages(
        chatId: String,
        limit: Int,
        lastMessageDate: Date?
    ) async throws(MessageManagerError) -> [MessageResponse]
}

final class MessageManager: MessageManagerProtocol {
    
    private var listener: ListenerRegistration?
    private let database = Firestore.firestore()
    private let subject = PassthroughSubject<[MessageResponse], Never>()
    private let chatSessionStartDate = Date()
    
    deinit {
        self.listener?.remove()
    }
    
    func observeChat(id: String) -> AnyPublisher<[MessageResponse], Never> {
        listener?.remove()
        
        listener = database
            .collection(FirestoreCollections.chats.rawValue)
            .document(id).collection(FirestoreCollections.messages.rawValue)
            .whereField(FirestoreFields.Message.createdAt.rawValue, isGreaterThan: chatSessionStartDate)
            .order(by: FirestoreFields.Message.createdAt.rawValue, descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documentChanges else { return }
                let newDocuments = documents.filter({ $0.type == .added }).map({ $0.document })
                self?.subject.send(newDocuments.compactMap({ try? $0.data(as: MessageResponse.self) }))
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func sendMessage(message: MessageRequest) async throws(MessageManagerError) {
        let dbRef = database.collection(FirestoreCollections.chats.rawValue).document(message.chatId)
        
        let messageData: [String: Any] = [
            FirestoreFields.Message.senderId.rawValue: message.senderId,
            FirestoreFields.Message.text.rawValue: message.text,
            FirestoreFields.Message.images.rawValue: message.images,
            FirestoreFields.Message.createdAt.rawValue: FieldValue.serverTimestamp()
        ]
        
        let messageRef = dbRef.collection(FirestoreCollections.messages.rawValue).document()
        
        let chatData: [String: Any] = [
            FirestoreFields.Chat.lastMessage.rawValue: message.text,
            FirestoreFields.Chat.lastMessageTime.rawValue: FieldValue.serverTimestamp(),
            FirestoreFields.Chat.lastMessageSender.rawValue: message.senderId
        ]
        
        let batch = database.batch()
        batch.updateData(chatData, forDocument: dbRef)
        batch.setData(messageData, forDocument: messageRef)
        
        do {
            try await batch.commit()
        } catch {
            throw .uploadError(error)
        }
    }
    
    func fetchMessages(chatId: String, limit: Int, lastMessageDate: Date?) async throws(MessageManagerError) -> [MessageResponse] {
        var query = database
            .collection(FirestoreCollections.chats.rawValue)
            .document(chatId)
            .collection(FirestoreCollections.messages.rawValue)
            .order(by: FirestoreFields.Message.createdAt.rawValue, descending: true)
            .limit(to: limit)
        
        if let lastMessageDate = lastMessageDate {
            let firestoreTimestamp = Timestamp(date: lastMessageDate)
            query = query.start(after: [firestoreTimestamp])
        }
        do {
            let snapshot = try await query.getDocuments()
            return snapshot.documents.compactMap({ try? $0.data(as: MessageResponse.self) })
        } catch {
            throw .fetchError(error)
        }
    }
}

