//
//  FriendsManagementCoordinator.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 6.05.26.
//

import Foundation
import Observation
import SwiftUI

protocol FriendsManagementCoordinatorProtocol {
    func push(route: FriendsManagementRoutes)
    func pop()
}

@Observable
final class FriendsManagementCoordinator: FriendsManagementCoordinatorProtocol {
    
    var path: NavigationPath = .init()
    
    func push(route: FriendsManagementRoutes) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
}

extension FriendsManagementCoordinator {
    func getView(route: FriendsManagementRoutes, viewModel: FriendsManagementViewModel) -> some View {
        switch route {
        case .findUsers:
            SearchFriendsView(viewModel: viewModel)
        }
    }
}
