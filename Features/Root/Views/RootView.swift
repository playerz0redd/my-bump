//
//  ContentView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 13.04.26.
//

import SwiftUI
import Combine

struct RootView: View {
    
    @State private var authViewModel: AuthViewModel
    
    private let appDependencyContainer: AppDependencyContainer
    
    init(appDependencyContainer: AppDependencyContainer) {
        self.appDependencyContainer = appDependencyContainer
        _authViewModel = State(wrappedValue: appDependencyContainer.makeAuthFactory().buildAuthViewModel())
    }
    
    var body: some View {
        if authViewModel.isSignedIn {
            ConfiguratedTabView(container: appDependencyContainer)
        } else {
            AuthFlowView(viewModel: authViewModel)
        }
    }
}

