//
//  ChatModelMapper.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation

protocol ChatModelMapperProtocol {
    func mapChats(chats: [ChatDTO]) async throws(ChatServiceError) -> [ChatModel]
}

final class ChatModelMapper: ChatModelMapperProtocol {
    
    private let userStorageManager: UserStorageManagerProtocol
    private let userSessionManager: UserSessionProtocol
    private let cloudStorageManager: CloudStorageManagerProtocol
    
    init(userStorageManager: UserStorageManagerProtocol, userSessionManager: UserSessionProtocol, cloudStorageManager: CloudStorageManagerProtocol) {
        self.userStorageManager = userStorageManager
        self.userSessionManager = userSessionManager
        self.cloudStorageManager = cloudStorageManager
    }
    
    func mapChats(chats: [ChatDTO]) async throws(ChatServiceError) -> [ChatModel] {
        guard let id = userSessionManager.userId else { throw .fetchUserIdError }
        return await chats.concurrentMap({ [weak self] in
            await self?.mapSingleChat(chat: $0, myId: id)
        })
    }
    
    private func mapSingleChat(chat: ChatDTO, myId: String) async -> ChatModel? {
        guard let id = chat.id,
              let member = chat.members.first(where: { $0 != myId }),
              let user = await userStorageManager.getUser(with: member)
        else { return nil }
        
        return ChatModel(
            id: id,
            userWithName: user.name,
            avatar: cloudStorageManager.getUrl(id: user.avatarPath, width: 50, height: 50),
            lastMessage: chat.lastMessage == nil ? "No messages yet" : chat.lastMessage,
            lastMessageTime: chat.lastMessageTime?.chatFormattedString,
            lastMessageUserId: user.id,
            unreadCount: "\(3)"
        )
    }
}
