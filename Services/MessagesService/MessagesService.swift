//
//  MessagesService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation
import Combine

protocol MessagesServiceProtocol {
    var messagesPublisher: AnyPublisher<[MessageResponse], Never> { get }
    func sendMessage(text: String?, images: [Data]) async throws(MessagesServiceError)
    func fetchMessages() async throws(MessagesServiceError) -> [MessageResponse]
}

final class MessagesService: MessagesServiceProtocol {
    
    private var lastMessageDate: Date?
    
    private let messageManager: MessageManagerProtocol
    private let cloudStorageManager: CloudStorageManagerProtocol
    private let userSessionManager: UserSessionProtocol
    
    private let messageLimit: Int = 50
    private let chatId: String
    
    var messagesPublisher: AnyPublisher<[MessageResponse], Never> {
        messageManager.observeChat(id: chatId)
    }
    
    init(chatId: String, dependency: DependencyContainer) {
        self.chatId = chatId
        self.messageManager = dependency.messageManager
        self.cloudStorageManager = dependency.cloudStorageManager
        self.userSessionManager = dependency.userSessionManager
    }
    
    func sendMessage(text: String?, images: [Data]) async throws(MessagesServiceError) {
        guard let myId: String = userSessionManager.userId else { throw .fetchUserIdError }
        
        do {
            let imageUrls = try await images.concurrentMap({
                try await self.cloudStorageManager.uploadImage(image: $0)
            })
            let messageRequest = MessageRequest(chatId: chatId, senderId: myId, text: text, images: imageUrls)
            try await messageManager.sendMessage(message: messageRequest)
        } catch let error as CloudStorageError {
            throw .uploadImagesError(error)
        } catch let error as MessageManagerError {
            throw .sendError(error)
        } catch {
            throw .unknown(error)
        }
    }
    
    func fetchMessages() async throws(MessagesServiceError) -> [MessageResponse] {
        do {
            let messages = try await messageManager.fetchMessages(
                chatId: chatId,
                limit: messageLimit,
                lastMessageDate: lastMessageDate
            )
            lastMessageDate = messages.last?.createdAt
            return messages
        } catch {
            throw .fetchError(error)
        }
    }
}

extension MessagesService {
    struct DependencyContainer {
        let messageManager: MessageManagerProtocol
        let cloudStorageManager: CloudStorageManagerProtocol
        let userSessionManager: UserSessionProtocol
    }
}
