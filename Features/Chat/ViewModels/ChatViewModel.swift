//
//  ChatViewModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation
import Observation
import Combine

@MainActor @Observable
final class ChatViewModel {
    
    var messages: [MessageModel] = []
    var messageText: String = ""
    var isOpenedAttachmentView: Bool = false
    var messageError: MessagesServiceError?
    
    private let messagesMapper: MessagesModelMapperProtocol
    private let messagesService: MessagesServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(dependency: DependencyContainer) {
        self.messagesMapper = dependency.messagesMapper
        self.messagesService = dependency.messagesService
        fetchMessages()
        observeChat()
    }
    
    func sendMessage() {
        Task {
            do {
                try await messagesService.sendMessage(text: messageText, images: [])
            } catch let error as MessagesServiceError {
                self.messageError = error
            }
        }
    }
    
    func fetchMessages() {
        Task {
            do {
                let rawMessages = try await self.messagesService.fetchMessages()
                self.messages += self.messagesMapper.mapMessages(messages: rawMessages)
            } catch let error as MessagesServiceError {
                self.messageError = error
            }
        }
    }
    
    func openAttachments() {
        isOpenedAttachmentView = true
    }
    
    private func observeChat() {
        messagesService
            .messagesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] messages in
                guard let self = self else { return }
                
                let incomingMessages = self.messagesMapper.mapMessages(messages: messages)
                
                for message in incomingMessages {
                    if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
                        self.messages[index] = message
                    } else {
                        self.messages.insert(message, at: 0)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
}

extension ChatViewModel {
    struct DependencyContainer {
        let messagesMapper: MessagesModelMapperProtocol
        let messagesService: MessagesServiceProtocol
    }
}
