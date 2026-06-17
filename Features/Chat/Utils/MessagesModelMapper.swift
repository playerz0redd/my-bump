//
//  MessagesModelMapper.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation

protocol MessagesModelMapperProtocol {
    func mapMessages(messages: [MessageResponse]) -> [MessageModel]
}

final class MessagesModelMapper: MessagesModelMapperProtocol {
    
    private let cloudStorageManager: CloudStorageManagerProtocol
    private let userSessionManager: UserSessionProtocol
    
    init(cloudStorageManager: CloudStorageManagerProtocol, userSessionManager: UserSessionProtocol) {
        self.cloudStorageManager = cloudStorageManager
        self.userSessionManager = userSessionManager
    }
    
    func mapMessages(messages: [MessageResponse]) -> [MessageModel] {
        messages.map({ dto in
            
            let images = dto.image?.compactMap({ cloudStorageManager.getUrl(id: $0, width: 200, height: 200)})
            
            return MessageModel(
                id: dto.messageId ?? "asd",
                text: dto.text,
                images: images,
                messageTime: dto.createdAt.timeString,
                senderId: dto.senderId,
                isMyMessage: dto.senderId == userSessionManager.userId
            ) })
    }
}
