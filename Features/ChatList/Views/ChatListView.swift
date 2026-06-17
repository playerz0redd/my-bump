//
//  ChatListView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 8.06.26.
//

import Foundation
import SwiftUI

struct ChatListView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ChatsViewController
    
    @ObservedObject private var viewModel: ChatListViewModel
    
    init(viewModel: ChatListViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> ChatsViewController {
        let controller = ChatsViewController(viewModel: viewModel)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ChatsViewController, context: Context) { }
}
