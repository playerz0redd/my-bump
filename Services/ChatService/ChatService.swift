//
//  ChatService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation
import Combine

protocol ChatServiceProtocol {
    var chatsPublisher: AnyPublisher<[ChatDTO], Never>? { get }
    func createChat(userWith id: String) async throws(ChatServiceError)
    func removeChat(chat id: String)
    func fetchChats() async throws(ChatServiceError) -> [ChatDTO]
}

final class ChatService: ChatServiceProtocol {
    
    private let chatManager: ChatManagerProtocol
    private let userSessionManager: UserSessionProtocol
    private let userStorageManager: UserStorageManagerProtocol
    private let cloudStorageManager: CloudStorageManagerProtocol
    
    init(dependency: DependencyContainer) {
        self.chatManager = dependency.chatManager
        self.userSessionManager = dependency.userSessionManager
        self.userStorageManager = dependency.userStorageManager
        self.cloudStorageManager = dependency.cloudStorageManager
    }
    
    var chatsPublisher: AnyPublisher<[ChatDTO], Never>? {
        guard let id = userSessionManager.userId else {
            assertionFailure("Could not fetch user id")
            return nil
        }
        return chatManager
            .getChatsPublisher(forUser: id)
            .eraseToAnyPublisher()
    }
    
    func fetchChats() async throws(ChatServiceError) -> [ChatDTO] {
        guard let myId = userSessionManager.userId else { throw .fetchUserIdError }
        do {
            return try await chatManager.fetchChats(forUser: myId)
        } catch {
            throw .fetchChatsError(error)
        }
    }
    
    func createChat(userWith id: String) async throws(ChatServiceError) {
        guard let myId = userSessionManager.userId else { throw .fetchUserIdError }
        do {
            try await chatManager.createChat(userFromId: myId, userToId: id)
        } catch {
            throw .createChatError(error)
        }
    }
    
    func removeChat(chat id: String) {
        chatManager.removeChat(chat: id)
    }
}

extension ChatService {
    struct DependencyContainer {
        let chatManager: ChatManagerProtocol
        let userSessionManager: UserSessionProtocol
        let userStorageManager: UserStorageManagerProtocol
        let cloudStorageManager: CloudStorageManagerProtocol
    }
}
