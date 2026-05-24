//
//  FriendsManagementFlowView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 6.05.26.
//

import Foundation
import SwiftUI

struct FriendsManagementFlowView: View {
    
    @Bindable private var viewModel: FriendsManagementViewModel
    @State private var coordinator: FriendsManagementCoordinator = .init()
    
    init(viewModel: FriendsManagementViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            FriendsManagementView(viewModel: viewModel, coordinator: coordinator)
                .navigationDestination(for: FriendsManagementRoutes.self) { route in
                    coordinator.getView(route: route, viewModel: viewModel)
                }
        }
    }
}
