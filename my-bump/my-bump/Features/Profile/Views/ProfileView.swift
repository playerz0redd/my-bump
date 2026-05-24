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
                VStack(spacing: 30) {
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
        AuthButton(title: "SIGN OUT", action: viewModel.signOut)
    }
}

private extension ProfileView {
    func switchButton(type: ProfileViewModel.SwitchButton, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(Circle().foregroundStyle(getColor(for: type)))
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .toggleStyle(.switch)
            }
            
            Text(type.title)
                .font(.system(size: 22, weight: .bold))
            
            Text(type.caption)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
        }
        .padding(30)
        .background(RoundedRectangle(cornerRadius: 50).foregroundStyle(.white))
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
            Text("Privacy Playground")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 10)
            
            Text("\(viewModel.privacyStatus.title) MODE ACTIVE")
                .foregroundStyle(textColor(status: viewModel.privacyStatus))
                .font(.system(size: 15, weight: .semibold))
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(minWidth: 220)
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
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.black)
        }
    }
}

private extension ProfileView {
    @ViewBuilder
    var avatarView: some View {
        KFImage(viewModel.avatarPath)
            .placeholder {
                Image(systemName: "person.icloud.fill")
                    .font(.system(size: 65))
                    .foregroundStyle(.white)
            }
            .resizable()
            .frame(width: 115, height: 115)
            .clipShape(RoundedRectangle(cornerRadius: 45))
            .id(viewModel.avatarPath)
            .shadow(color: .black.opacity(0.15), radius: 6, x: 3, y: 7)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: 55)
                    .foregroundStyle(Gradients.pinkGradient)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 3, y: 7)
            }
            .onTapGesture {
                isShowingDialog = true
            }
            .modifier(ImageSelectorModifier(isShowingDialog: $isShowingDialog, onImagePick: viewModel.onImagePick))
    }
}
