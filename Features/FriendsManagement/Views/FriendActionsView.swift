//
//  FriendActionsView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 12.05.26.
//

import Foundation
import SwiftUI

struct FriendActionsView: View {
    
    private var viewModel: FriendsManagementViewModel
    @State private var offsetY: CGFloat = .zero
    
    private let selectedFriend: FriendModel
    
    init(viewModel: FriendsManagementViewModel, selectedFriend: FriendModel) {
        self.viewModel = viewModel
        self.selectedFriend = selectedFriend
    }
    
    var body: some View {
        VStack(spacing: Constants.mainViewSpacing) {
            headerView
            
            buttonSection
            
            dismissButton
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.mainViewHorizontalPadding)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: Constants.mainViewRectangleRadius)
                .foregroundStyle(.lightGray.opacity(Constants.mainViewBackgroundColorOpacity))
        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    offsetY = value.translation.height / Constants.gestureCoefficient
                })
                .onEnded({ value in
                    if value.translation.height > Constants.gestureEndBorderValue {
                        viewModel.isShowingFriendActions = false
                    } else {
                        offsetY = .zero
                    }
                })
        )
        .offset(y: offsetY)
        .animation(.bouncy, value: offsetY)
    }
}

private extension FriendActionsView {
    var dismissButton: some View {
        Button(action: { viewModel.isShowingFriendActions = false }) {
            Text(.dismiss)
                .font(.system(size: Constants.dismissButtonFontSize, weight: .semibold))
                .foregroundStyle(.darkGray)
        }
    }
}

private extension FriendActionsView {
    var buttonSection: some View {
        VStack(spacing: Constants.buttonsSpacing) {
            ForEach(FriendsManagementViewModel.FriendActions.allCases, id: \.self) { action in
                buttonView(action: action)
            }
        }
    }
}

private extension FriendActionsView {
    func buttonView(action: FriendsManagementViewModel.FriendActions) -> some View {
        Button(action: { viewModel.buttonAction(action: action, friend: selectedFriend) }) {
            HStack {
                Image(systemName: action.icon)
                    .font(.system(size: Constants.buttonImageFont, weight: .semibold))
                    .frame(width: Constants.buttonImageFrame.width, height: Constants.buttonImageFrame.height)
                    .foregroundStyle(action.iconColor)
                    .padding(Constants.buttonImagePadding)
                    .background {
                        Circle()
                            .foregroundStyle(action.iconBackgroundColor)
                    }
                
                Text(action.title)
                    .font(.system(size: Constants.buttonTitleFont, weight: .semibold))
                    .foregroundStyle(.black)
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.buttonVerticalPadding)
            .background {
                Capsule()
                    .foregroundStyle(action.buttonColor.opacity(Constants.buttonBackgroundOpacity))
            }
        }
    }
}

private extension FriendActionsView {
    var headerView: some View {
        HStack(spacing: Constants.headerSpacing) {
            PersonAvatarView(firstLetter: viewModel.avatarFirstLetter(friend: selectedFriend), avatarPath: viewModel.getAvatarUrl(forImage: selectedFriend.avatarPath))
            
            infoSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var infoSection: some View {
        VStack(alignment: .leading) {
            Text(selectedFriend.name)
                .font(.system(size: Constants.friendNameFontSize, weight: .bold))
                .foregroundStyle(.black)
            
            Text(.manageRelationship)
                .font(.system(size: Constants.captionFontSize, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}


private extension FriendsManagementViewModel.FriendActions {
    var iconBackgroundColor: Color {
        switch self {
        case .viewProfile:
                .white
        case .ghostMode:
                .white
        case .removeFriend:
                .darkPink
        }
    }
    
    var buttonColor: Color {
        switch self {
        case .viewProfile:
                .white
        case .ghostMode:
                .white
        case .removeFriend:
                .red
        }
    }
    
    var iconColor: Color {
        switch self {
        case .viewProfile:
                .black
        case .ghostMode:
                .black
        case .removeFriend:
                .white
        }
    }
    
    var textColor: Color {
        switch self {
        case .viewProfile:
                .black
        case .ghostMode:
                .black
        case .removeFriend:
                .darkPink
        }
    }
}

private extension FriendActionsView {
    enum Constants {
        static let mainViewSpacing: CGFloat = 20
        static let mainViewHorizontalPadding: CGFloat = 20
        static let mainViewVerticalPadding: CGFloat = 30
        static let mainViewRectangleRadius: CGFloat = 50
        static let mainViewBackgroundColorOpacity: CGFloat = 0.7
        static let gestureCoefficient: CGFloat = 10
        static let gestureEndBorderValue: CGFloat = 100
        static let dismissButtonFontSize: CGFloat = 21
        static let buttonsSpacing: CGFloat = 10
        static let buttonImageFont: CGFloat = 27
        static let buttonImageFrame: CGSize = .init(width: 30, height: 30)
        static let buttonImagePadding: CGFloat = 7
        static let buttonTitleFont: CGFloat = 21
        static let buttonHorizontalPadding: CGFloat = 20
        static let buttonVerticalPadding: CGFloat = 10
        static let buttonBackgroundOpacity: CGFloat = 0.8
        static let headerSpacing: CGFloat = 10
        static let friendNameFontSize: CGFloat = 23
        static let captionFontSize: CGFloat = 18
    }
}
