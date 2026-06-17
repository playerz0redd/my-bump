//
//  ChatListViewModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {
    
    @Published var visibleChats: [ChatModel] = []
    @Published var searchString = "" {
        didSet { searchChats(search: searchString) }
    }
    @Published var chatError: ChatServiceError?
    
    var onChatSelection: ((String) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    private var allChats: [ChatDTO] = [] {
        didSet { mapChats() }
    }
    private var chats: [ChatModel] = [] {
        willSet { if visibleChats == chats { visibleChats = newValue } }
    }
    
    private let chatsService: ChatServiceProtocol
    private let chatsMapper: ChatModelMapperProtocol
    
    init(chatsService: ChatServiceProtocol, chatsMapper: ChatModelMapperProtocol) {
        self.chatsMapper = chatsMapper
        self.chatsService = chatsService
        fetchChats()
        observeChats()
    }
    
    func openChat(with id: String) {
        onChatSelection?(id)
    }
    
    func searchChats(search: String) {
        visibleChats = searchString.isEmpty ? chats : chats.filter({ $0.userWithName.lowercased().contains(searchString.lowercased())})
    }
    
    func fetchChats() {
        Task {
            do {
                self.allChats = try await chatsService.fetchChats()
            } catch let error as ChatServiceError {
                self.chatError = error
            }
        }
    }
    
    private func mapChats() {
        Task {
            do {
                chats = try await chatsMapper.mapChats(chats: allChats)
            } catch let error as ChatServiceError {
                self.chatError = error
            }
        }
    }
    
    private func observeChats() {
        chatsService.chatsPublisher?
            .receive(on: RunLoop.main)
            .sink { [weak self] chats in
                self?.allChats = chats
            }
            .store(in: &cancellables)
    }
}
