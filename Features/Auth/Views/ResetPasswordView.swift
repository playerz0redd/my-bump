//
//  ResetPasswordView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.04.26.
//

import Foundation
import SwiftUI

struct ResetPasswordView: View {
    
    @Bindable private var viewModel: AuthViewModel
    
    private let currentState: AuthViewModel.AuthState.ResetPasswordState
    
    init(viewModel: AuthViewModel, currentState: AuthViewModel.AuthState.ResetPasswordState) {
        self.viewModel = viewModel
        self.currentState = currentState
    }
    
    var body: some View {
        ZStack {
            switch currentState {
            case .inputEmail:
                ResetInputEmailView(viewModel: viewModel)
            case .confirmation:
                ResetConfirmationView(viewModel: viewModel)
            }
        }
    }
}

fileprivate struct ResetConfirmationView: View {
    
    @Bindable private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        confirmationView
            .padding(.horizontal, ResetPasswordConstants.backgroundPadding)
            .transition(.opacity.combined(with: .scale))
    }
}

private extension ResetConfirmationView {
    
    var confirmationView: some View {
        VStack(spacing: ResetPasswordConstants.viewsSpacing) {
            symbolAnimationView
            
            infoView
            
            AuthButton(title: .backToLoginConfirm, action: { viewModel.changeAuthState(to: .login) })
            
            resendMailView
        }
    }
    
    var resendMailView: some View {
        HStack(spacing: ResetPasswordConstants.resendTextSpacing) {
            Text(.iDidntReceiveAnEmail)
                .foregroundStyle(.darkGray)
            
            Button(action: viewModel.changePassword) {
                Text(.resend)
                    .fontWeight(.semibold)
                    .underline()
                    .foregroundStyle(.darkPink)
            }
        }
        .font(.system(size: ResetPasswordConstants.captionFontSize, weight: .medium))
    }
    
    var infoView: some View {
        VStack(spacing: ResetPasswordConstants.infoViewSpacing) {
            Text(.checkYourInbox)
                .font(.system(size: ResetPasswordConstants.titleFontSize, weight: .bold))
                .foregroundStyle(.black)
            
            
            VStack(spacing: ResetPasswordConstants.sentLinkTextsSpacing) {
                Text(.weSentALinkToResetYourPasswordTo)
                    .font(.system(size: ResetPasswordConstants.sentLinkTextFontSize, weight: .medium))
                
                Text(viewModel.resetPasswordEmail)
                    .font(.system(size: ResetPasswordConstants.sentLinkTextFontSize, weight: .semibold))
                    .foregroundStyle(.darkPink)
            }
            .foregroundStyle(.darkGray)
        }
    }
    
    var symbolAnimationView: some View {
        PhaseAnimator(AnimationSymbols.allCases, content: { phase in
            Image(systemName: phase.symbol)
                .font(.system(size: ResetPasswordConstants.imageSize))
                .foregroundStyle(.pink.gradient)
                .shadow(
                    color: .pink.opacity(ResetPasswordConstants.shadowColorOpacity),
                    radius: ResetPasswordConstants.shadowRadius,
                    x: ResetPasswordConstants.shadowX,
                    y: ResetPasswordConstants.shadowY
                )
        }, animation: { _ in
                .bouncy.delay(0.2)
        })
        .frame(width: ResetPasswordConstants.phaseAnimationSize.width, height: ResetPasswordConstants.phaseAnimationSize.height)
        .padding(ResetPasswordConstants.symbolAnimationBackgroundPadding)
        .background {
            RoundedRectangle(cornerRadius: ResetPasswordConstants.defaultCornerRadius)
                .foregroundStyle(.white)
                .shadow(
                    color: .black.opacity(ResetPasswordConstants.shadowColorOpacity),
                    radius: ResetPasswordConstants.shadowRadius,
                    x: ResetPasswordConstants.shadowX,
                    y: ResetPasswordConstants.shadowY
                )
        }
    }
    
    enum AnimationSymbols: CaseIterable {
        case email
        case key
        case plane
        case cloud
        
        var symbol: String {
            switch self {
            case .email:        
                "envelope.fill"
            case .key:
                "key.horizontal.fill"
            case .plane:
                "paperplane.fill"
            case .cloud:
                "arrow.trianglehead.clockwise.icloud.fill"
            }
        }
    }
}

fileprivate struct ResetInputEmailView: View {
    
    @Bindable private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        inputEmailView
            .padding(.horizontal, ResetPasswordConstants.backgroundPadding)
            .transition(.opacity.combined(with: .scale))
    }
}

private extension ResetInputEmailView {
    
    var inputEmailView: some View {
        VStack(spacing: ResetPasswordConstants.viewsSpacing) {
            headerView
            
            emailInputSection
            
            backToLoginView
        }
    }
    
    var emailInputSection: some View {
        VStack(spacing: ResetPasswordConstants.emailInputSectionSpacing) {
            InputField(
                text: $viewModel.resetPasswordEmail,
                errorMessage: viewModel.resetPasswordEmailError?.message,
                fieldType: .email
            )
            
            AuthButton(title: .sendResetLink, action: viewModel.changePassword)
                .shadow(
                    color: .pink.opacity(ResetPasswordConstants.shadowColorOpacity),
                    radius: ResetPasswordConstants.shadowRadius,
                    x: ResetPasswordConstants.shadowX,
                    y: ResetPasswordConstants.shadowY
                )
            
            AuthErrorView(authError: viewModel.resetPasswordError)
        }
        .padding(ResetPasswordConstants.backgroundPadding)
        .background {
            RoundedRectangle(cornerRadius: ResetPasswordConstants.defaultCornerRadius)
                .foregroundStyle(.white)
                .shadow(
                    color: .black.opacity(ResetPasswordConstants.shadowColorOpacity),
                    radius: ResetPasswordConstants.shadowRadius,
                    x: ResetPasswordConstants.shadowX,
                    y: ResetPasswordConstants.shadowY
                )
        }
    }
    
    var backToLoginView: some View {
        Button {
            viewModel.changeAuthState(to: .login)
        } label: {
            HStack {
                Image(systemName: "chevron.backward")
                
                Text(.backToLogin)
            }
            .foregroundStyle(.darkGray)
            .font(.system(size: ResetPasswordConstants.backLoginButtonFontSize, weight: .medium))
        }

    }
    
    var headerView: some View {
        VStack(spacing: ResetPasswordConstants.headerSpacing) {
            keyView
            
            infoView
        }
    }
    
    var infoView: some View {
        VStack(spacing: ResetPasswordConstants.infoViewSpacing) {
            Text(.forgotPassword)
                .font(.system(size: ResetPasswordConstants.titleFontSize, weight: .bold))
                .foregroundStyle(.black)
            
            Text(.resetPasswordTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: ResetPasswordConstants.captionFontSize, weight: .medium))
                .foregroundStyle(.darkGray)
        }
        
    }
    
    var keyView: some View {
        Image(systemName: "key.horizontal.fill")
            .font(.system(size: ResetPasswordConstants.imageSize))
            .foregroundStyle(.darkPink)
            .padding(ResetPasswordConstants.backgroundPadding)
            .background {
                Circle()
                    .foregroundStyle(.white)
            }
    }
}

private enum ResetPasswordConstants {
    static let backgroundPadding: CGFloat = 30
    static let viewsSpacing: CGFloat = 30
    static let resendTextSpacing: CGFloat = 3
    static let captionFontSize: CGFloat = 17
    static let titleFontSize: CGFloat = 34
    static let sentLinkTextFontSize: CGFloat = 18
    static let sentLinkTextsSpacing: CGFloat = 5
    static let phaseAnimationSize: CGSize = CGSize(width: 80, height: 80)
    static let imageSize: CGFloat = 55
    static let shadowColorOpacity: CGFloat = 0.15
    static let shadowRadius: CGFloat = 10
    static let shadowX: CGFloat = 7
    static let shadowY: CGFloat = 7
    static let infoViewSpacing: CGFloat = 15
    static let symbolAnimationBackgroundPadding: CGFloat = 35
    static let defaultCornerRadius: CGFloat = 40
    static let emailInputSectionSpacing: CGFloat = 20
    static let backLoginButtonFontSize: CGFloat = 18
    static let headerSpacing: CGFloat = 20
}
