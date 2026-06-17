//
//  ProfileView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 20.05.26.
//

import Foundation
import SwiftUI
import Kingfisher
import PhotosUI

struct ProfileView: View {
    
    @Bindable private var viewModel: ProfileViewModel
    @State private var isShowingCamera: Bool = false
    @State private var selectedGalleryItem: PhotosPickerItem?
    @State private var isShowingGallery: Bool = false
    @State private var isShowingDialog = false
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: Constants.mainSpacing) {
                    avatarView
                    infoBlock
                    privacyStatusView
                }
                switchButton(type: .freezeLocation, isOn: $viewModel.isFreezeActive)
                switchButton(type: .blurLocation, isOn: $viewModel.isBlurActive)
                
                signOutButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .background {
            Gradients.backgroundGradient
                .ignoresSafeArea()
        }
    }
}

private extension ProfileView {
    var signOutButton: some View {
        AuthButton(title: LocalizedStringResource.signOut, action: viewModel.signOut)
    }
}

private extension ProfileView {
    func switchButton(type: ProfileViewModel.SwitchButton, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: Constants.buttonImageSize))
                    .foregroundStyle(.black)
                    .padding(Constants.buttonPadding)
                    .background(Circle().foregroundStyle(getColor(for: type)))
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .toggleStyle(.switch)
            }
            
            Text(type.title)
                .font(.system(size: Constants.switchTitleFontSize, weight: .bold))
            
            Text(type.caption)
                .font(.system(size: Constants.switchCaptionFontSize))
                .foregroundStyle(.secondary)
        }
        .padding(Constants.switchButtonPadding)
        .background(RoundedRectangle(cornerRadius: Constants.switchButtonCornerRadius).foregroundStyle(.white))
    }
    
    func getColor(for type: ProfileViewModel.SwitchButton) -> Color {
        switch type {
        case .freezeLocation:
                .blue
        case .blurLocation:
                .lightPink
        }
    }
}

private extension ProfileView {
    var privacyStatusView: some View {
        HStack {
            Text(.privacyPlayground)
                .font(.system(size: Constants.privacyStatusFontSize, weight: .bold))
                .foregroundStyle(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: Constants.privacyStatusSpacerWidth)
            
            Text("")
                .foregroundStyle(textColor(status: viewModel.privacyStatus))
                .font(.system(size: Constants.buttonModeFont, weight: .semibold))
                .padding(.horizontal)
                .padding(.vertical, Constants.modeVerticalPadding)
                .frame(minWidth: Constants.modeMinWidth)
                .background {
                    Capsule()
                        .foregroundStyle(backgroundColor(status: viewModel.privacyStatus))
                }
        }
    }
    
    func backgroundColor(status: ProfileViewModel.PrivacyStatus) -> Color {
        switch status {
        case .ghostMode:
                .lightPink
        case .defaultMode:
                .lightGreen
        }
    }
    
    func textColor(status: ProfileViewModel.PrivacyStatus) -> Color {
        switch status {
        case .ghostMode:
                .darkPink
        case .defaultMode:
                .green
        }
    }
}

private extension ProfileView {
    @ViewBuilder
    var infoBlock: some View {
        if let username = viewModel.username {
            Text(username)
                .font(.system(size: Constants.usernameFont, weight: .bold))
                .foregroundStyle(.black)
        }
    }
}

private extension ProfileView {
    @ViewBuilder
    var avatarView: some View {
        KFImage(viewModel.avatarPath)
            .placeholder {
                Image(systemName: Assets.person.rawValue)
                    .font(.system(size: Constants.imagePlaceholderFontSize))
                    .foregroundStyle(.white)
            }
            .resizable()
            .frame(width: Constants.imageFrame, height: Constants.imageFrame)
            .clipShape(RoundedRectangle(cornerRadius: Constants.userImageCornerRadius))
            .id(viewModel.avatarPath)
            .shadow(
                color: .black.opacity(Constants.shadowColorOpacity),
                radius: Constants.shadowRadius,
                x: Constants.shadowX,
                y: Constants.shadowY
            )
            .padding(Constants.userImagePadding)
            .background {
                RoundedRectangle(cornerRadius: Constants.userImageBackgroundCornerRadius)
                    .foregroundStyle(Gradients.pinkGradient)
                    .shadow(
                        color: .black.opacity(Constants.shadowColorOpacity),
                        radius: Constants.shadowRadius,
                        x: Constants.shadowX,
                        y: Constants.shadowY
                    )
            }
            .onTapGesture {
                isShowingDialog = true
            }
            .modifier(ImageSelectorModifier(isShowingDialog: $isShowingDialog, onImagePick: viewModel.onImagePick))
    }
}

private extension ProfileView {
    
    enum Constants {
        static let mainSpacing: CGFloat = 30
        static let buttonImageSize: CGFloat = 32
        static let buttonPadding: CGFloat = 10
        static let buttonModeFont: CGFloat = 15
        static let switchTitleFontSize: CGFloat = 22
        static let switchCaptionFontSize: CGFloat = 16
        static let switchButtonPadding: CGFloat = 30
        static let switchButtonCornerRadius: CGFloat = 50
        static let modeVerticalPadding: CGFloat = 10
        static let privacyStatusFontSize: CGFloat = 22
        static let privacyStatusSpacerWidth: CGFloat = 10
        static let modeMinWidth: CGFloat = 220
        static let usernameFont: CGFloat = 28
        static let imagePlaceholderFontSize: CGFloat = 65
        static let imageFrame: CGFloat = 115
        static let userImageCornerRadius: CGFloat = 45
        static let shadowColorOpacity: CGFloat = 0.15
        static let shadowRadius: CGFloat = 6
        static let shadowX: CGFloat = 3
        static let shadowY: CGFloat = 7
        static let userImagePadding: CGFloat = 4
        static let userImageBackgroundCornerRadius: CGFloat = 55
    }
    
    enum Assets: String {
        case person = "person.icloud.fill"
    }
}
