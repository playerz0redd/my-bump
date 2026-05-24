//
//  SignInView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 15.04.26.
//

import Foundation
import SwiftUI

struct SignInView: View {
    
    @Bindable private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        signInView
            .transition(.opacity.combined(with: .scale))
            .onChange(of: viewModel.loginForm, viewModel.eraseAuthError)
    }
}

private extension SignInView {
    var signInView: some View {
        VStack(spacing: Constants.mainStackSpacing) {
            
            VStack(spacing: Constants.logoTextSpacing) {
                logoView
                
                appInfoView
            }
            
            formView
            
        }
        .animation(.easeIn, value: viewModel.loginValidationResult)
    }
}

private extension SignInView {
    var googleSignInButton: some View {
        Button(action: viewModel.googleSignIn) {
            HStack(spacing: Constants.authProviderSpacing) {
                
                Image(.googleLogo)
                    .resizable()
                    .frame(width: Constants.authProviderLogoFrame.width, height: Constants.authProviderLogoFrame.height)
                    .clipShape(.circle)
                
                Text(.continueWithGoogle)
                    .font(.system(size: Constants.authProviderTitleFontSize, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.authProviderVerticalPadding)
            .background {
                Capsule()
                    .stroke(Color.darkGray, lineWidth: Constants.capsuleLineWidth)
                    .shadow(
                        color: .black.opacity(Constants.shadowColorOpacity),
                        radius: Constants.shadowRadius,
                        x: Constants.shadowX,
                        y: Constants.shadowY
                    )
            }
        }
    }
}

private extension SignInView {
    var createAccountView: some View {
        HStack(spacing: Constants.createAccountSpacing) {
            Text(.newToThePlayground)
                .foregroundStyle(.darkGray)
                .fontWeight(.medium)
            
            Button(action: { viewModel.changeAuthState(to: .register) }) {
                Text(.createAccount)
                    .foregroundStyle(.darkPink)
                    .fontWeight(.semibold)
            }
        }
        .font(.system(size: Constants.captionFontSize))
    }
}

private extension SignInView {
    var dividerView: some View {
        HStack(spacing: Constants.dividerSpacing) {
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: Constants.dividerRectHeight)
            
            Text(.or)
                .font(.system(size: Constants.captionFontSize, weight: .semibold))
            
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: Constants.dividerRectHeight)
        }
        .foregroundStyle(.darkGray)
    }
}

private extension SignInView {
    var formView: some View {
        VStack(spacing: Constants.formElementsSpacing) {
            
            googleSignInButton
            
            dividerView
            
            inputSection
            
            AuthButton(title: .signInButtonTitle, action: viewModel.login)
            
            AuthErrorView(authError: viewModel.authError)
            
            createAccountView
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: Constants.formCornerRadius)
                .foregroundStyle(.white)
                .shadow(
                    color: .black.opacity(Constants.shadowColorOpacity),
                    radius: Constants.shadowRadius,
                    x: Constants.shadowX,
                    y: Constants.shadowY
                )
        }
        .padding()
        .animation(.easeIn, value: viewModel.authError)
    }
}

private extension SignInView {
    var inputSection: some View {
        VStack(spacing: Constants.inputSectionSpacing) {
            InputField(
                text: $viewModel.loginForm.email,
                errorMessage: viewModel.loginValidationResult.emailError?.message,
                fieldType: .email
            )
            
            InputField(
                text: $viewModel.loginForm.password,
                errorMessage: viewModel.loginValidationResult.passwordError?.message,
                fieldType: .password) {
                    forgetPasswordButton
                }
            
        }
    }
    
    var forgetPasswordButton: some View {
        Button(action: { viewModel.changeAuthState(to: .resetPassword(.inputEmail)) }) {
            Text(.forgot)
                .font(.system(size: Constants.captionFontSize, weight: .bold))
                .foregroundStyle(.pink.gradient)
        }
    }
}

private extension SignInView {
    var appInfoView: some View {
        VStack(spacing: Constants.mainStackSpacing) {
            Text(.neonPlay)
                .font(.title)
                .bold()
                .foregroundStyle(.pink.gradient)
            
            Text(.findTheVibeEnjoyThePlayground)
                .font(.system(size: Constants.captionFontSize, weight: .medium))
                .foregroundStyle(.darkGray)
        }
    }
}

private extension SignInView {
    var logoView: some View {
        Image(systemName: "location.circle.fill")
            .foregroundStyle(.darkPink)
            .font(.system(size: Constants.logoFontSize))
            .padding()
            .background {
                Circle()
                    .foregroundStyle(.white)
            }
    }
}

private extension SignInView {
    enum Constants {
        static let authProviderSpacing: CGFloat = 10
        static let authProviderLogoFrame: CGSize = CGSize(width: 32, height: 32)
        static let authProviderTitleFontSize: CGFloat = 19
        static let authProviderVerticalPadding: CGFloat = 10
        static let capsuleLineWidth: CGFloat = 1.5
        static let shadowRadius: CGFloat = 3
        static let shadowX: CGFloat = 5
        static let shadowY: CGFloat = 5
        static let shadowColorOpacity: CGFloat = 0.15
        static let dividerRectHeight: CGFloat = 1.5
        static let captionFontSize: CGFloat = 17
        static let logoTextSpacing: CGFloat = 7
        static let mainStackSpacing: CGFloat = 10
        static let createAccountSpacing: CGFloat = 3
        static let formElementsSpacing: CGFloat = 20
        static let inputSectionSpacing: CGFloat = 10
        static let dividerSpacing: CGFloat = 5
        static let formCornerRadius: CGFloat = 35
        static let logoFontSize: CGFloat = 42
    }
}
