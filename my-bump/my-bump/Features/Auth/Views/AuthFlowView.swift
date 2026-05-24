//
//  AuthFlowView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.04.26.
//

import Foundation
import SwiftUI

struct AuthFlowView: View {
    
    @Bindable private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Gradients.backgroundGradient
                .ignoresSafeArea()
            
            switch viewModel.authState {
            case .register:
                SignUpView(viewModel: viewModel)
            case .login:
                SignInView(viewModel: viewModel)
            case .resetPassword(let stage):
                ResetPasswordView(viewModel: viewModel, currentState: stage)
                    .transition(.opacity.combined(with: .scale))
                
            }
        }
        .animation(.bouncy, value: viewModel.authState)
    }
}

