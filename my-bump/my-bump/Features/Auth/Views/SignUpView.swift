//
//  SignUpView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.04.26.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    
    @Bindable private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        signUpView
            .transition(.opacity.combined(with: .scale))
            .onChange(of: viewModel.registrationForm, viewModel.eraseAuthError)
        
    }
}

private extension SignUpView {
    
    var signUpView: some View {
        VStack(spacing: Constants.mainSectionSpacing) {
            mainSection
            
            AuthErrorView(authError: viewModel.authError)
            
            haveAccountView
            
            agreementTextView
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

private extension SignUpView {
    var mainSection: some View {
        VStack(alignment: .leading, spacing: Constants.mainSectionSpacing) {
            headerView
            
            informationSectionView
            
            
            inputSection
            
            AuthButton(title: .joinTheSquad, action: viewModel.register)
            
        }
        .animation(.spring, value: viewModel.registrationValidationResult)
    }
}

private extension SignUpView {
    var agreementTextView: some View {
        Text(.privacyPolicy)
            .font(.system(size: Constants.footerFontSize))
            .foregroundStyle(.darkGray)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private extension SignUpView {
    var haveAccountView: some View {
        HStack(spacing: Constants.haveAccountTextsSpacing) {
            Text(.alreadyHaveAnAccount)
                .foregroundStyle(.darkGray)
                .fontWeight(.medium)
            
            Button(action: { viewModel.changeAuthState(to: .login) }) {
                Text(.signIn)
                    .foregroundStyle(.darkPink)
                    .bold()
                
            }
        }
        .font(.system(size: Constants.captionFontSize))
    }
}

private extension SignUpView {
    var inputSection: some View {
        VStack(spacing: Constants.inputSectionSpacing) {
            InputField(
                text: $viewModel.registrationForm.name,
                errorMessage: viewModel.getErrorMessage(for: .name),
                fieldType: .name
            )
            
            InputField(
                text: $viewModel.registrationForm.email,
                errorMessage: viewModel.getErrorMessage(for: .email),
                fieldType: .email
            )
            
            InputField(
                text: $viewModel.registrationForm.password,
                errorMessage: viewModel.getErrorMessage(for: .password),
                fieldType: .password
            )
            
            InputField(
                text: $viewModel.registrationForm.confirmPassword,
                errorMessage: viewModel.getErrorMessage(for: .confirmPassword),
                fieldType: .confirmPassword
            )
        }
    }
}

private extension SignUpView {
    var headerView: some View {
        HStack(spacing: Constants.headerSpacing) {
            Image(systemName: "location.circle.fill")
                .foregroundStyle(.darkPink)
                .font(.system(size: Constants.logoImageSize))
            
            Text(.neonPlay)
                .font(.system(size: Constants.appTitleFontSize, weight: .bold))
                .foregroundStyle(.darkPink)
            
            Spacer()
            
        }
    }

}

private extension SignUpView {
    var informationSectionView: some View {
        VStack(alignment: .leading, spacing: Constants.infoSectionSpacing) {
            Text(.createAccount)
                .font(.title)
                .bold()
            
            Text(.stepIntoTheKineticSocialMap)
                .foregroundStyle(.gray)
                .font(.system(size: Constants.captionFontSize, weight: .regular))
        }
    }
}

private extension SignUpView {
    enum Constants {
        static let mainSectionSpacing: CGFloat = 10
        static let formCornerRadius: CGFloat = 50
        static let shadowColorOpacity: CGFloat = 0.1
        static let shadowRadius: CGFloat = 10
        static let shadowX: CGFloat = 5
        static let shadowY: CGFloat = 5
        static let footerFontSize: CGFloat = 13
        static let haveAccountTextsSpacing: CGFloat = 3
        static let inputSectionSpacing: CGFloat = 10
        static let headerSpacing: CGFloat = 10
        static let infoSectionSpacing: CGFloat = 10
        static let captionFontSize: CGFloat = 16
        static let logoImageSize: CGFloat = 35
        static let appTitleFontSize: CGFloat = 25
    }
}
