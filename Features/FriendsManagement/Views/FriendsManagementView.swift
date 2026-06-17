//
//  FriendsManagementView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import SwiftUI

struct FriendsManagementView: View {
    
    @Bindable private var viewModel: FriendsManagementViewModel
    private var coordinator: FriendsManagementCoordinatorProtocol
    
    init(viewModel: FriendsManagementViewModel, coordinator: FriendsManagementCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack(spacing: Constants.mainViewSpacing) {
            
            ScrollView(showsIndicators: false) {
                
                HeaderView(firstNameLetter: "P")
                    .padding(.horizontal, Constants.headerHorizontalPadding)
                    .padding(.bottom)
                
                VStack(spacing: Constants.scrollViewSpacing) {
                    
                    findFriendsSection
                    
                    requestsView
                    
                    friendsView
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .animation(.bouncy, value: viewModel.requests)
            .animation(.bouncy, value: viewModel.visibleFriends)
            .animation(.bouncy, value: viewModel.isShowingAllFriends)
            .refreshable(action: viewModel.updateData)
        }
        .background {
            Gradients.backgroundGradient
                .ignoresSafeArea()
        }
        .disabled(viewModel.isShowingFriendActions)
        .blur(radius: viewModel.isShowingFriendActions ? Constants.blurRadius : 0)
        .onTapGesture {
            if viewModel.isShowingFriendActions {
                viewModel.isShowingFriendActions = false
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.isShowingFriendActions, let friend = viewModel.selectedFriend {
                FriendActionsView(viewModel: viewModel, selectedFriend: friend)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
        }
        .animation(.easeInOut, value: viewModel.isShowingFriendActions)
    }
}

private extension FriendsManagementView {
    @ViewBuilder
    var friendsView: some View {
        if !viewModel.friends.isEmpty {
            FriendsSectionView(
                title: LocalizedStringResource.myFriends,
                leadingContent: countView(count: viewModel.friends.count),
                trailingContent: FriendsSearchView(
                    text: $viewModel.searchBeetwenFriendsText,
                    caption: LocalizedStringResource.search
                ),
                mainContent: friendsListView
            )
        }
    }
    
    @ViewBuilder
    var requestsView: some View {
        if !viewModel.requests.isEmpty {
            FriendsSectionView(
                title: LocalizedStringResource.requests,
                leadingContent: countView(count: viewModel.requests.count),
                trailingContent: buttonWithoutBackground(
                    title: viewModel.isShowingAllRequests ? LocalizedStringResource.showLess: LocalizedStringResource.viewAll,
                    color: .darkPink,
                    action: { viewModel.isShowingAllRequests.toggle() }
                ),
                mainContent: requestsListView
            )
        }
    }
}

private extension FriendsManagementView {
    var friendsListView: some View {
        VStack(spacing: Constants.friendsSpacing) {
            
            ForEach(viewModel.visibleFriends, id: \.self) { friend in
                singleFriendView(friend: friend)
            }
            
            showMoreFriendsButton
        }
        .padding()
        .background {
            if !viewModel.visibleFriends.isEmpty {
                RoundedRectangle(cornerRadius: Constants.friendsCornerRadius)
                    .foregroundStyle(.white)
            }
        }
        .animation(.bouncy, value: viewModel.visibleFriends)
    }
    
    @ViewBuilder
    var showMoreFriendsButton: some View {
        if !viewModel.isShowingAllFriends && viewModel.shouldShowMoreFriends {
            buttonWithoutBackground(
                title: LocalizedStringResource.viewMoreFriends(viewModel.moreFriendsCount),
                color: .darkPink,
                action: { viewModel.isShowingAllFriends.toggle() }
            )
        } else if viewModel.isShowingAllFriends {
            buttonWithoutBackground(
                title: LocalizedStringResource.showLess,
                color: .darkPink,
                action: { viewModel.isShowingAllFriends.toggle() }
            )
        }
    }
}

private extension FriendsManagementView {
    func singleFriendView(friend: FriendModel) -> some View {
        HStack(spacing: Constants.friendViewHorizontalSpacing) {
            PersonAvatarView(firstLetter: String(friend.name.prefix(1)), avatarPath: viewModel.getAvatarUrl(forImage: friend.avatarPath))
            
            VStack(alignment: .leading, spacing: Constants.friendViewVerticalSpacing) {
                Text(friend.name)
                    .foregroundStyle(.black)
                    .font(.system(size: Constants.friendViewFontSize, weight: .semibold))
                
                Text(.live)
                    .foregroundStyle(.darkGray)
                    .font(.system(size: Constants.friendViewFontSize, weight: .semibold))
            }
            
            Spacer()
            
            Button(action: { viewModel.openFriendActions(friend: friend) }) {
                Image(systemName: Assets.dots)
                    .rotationEffect(.degrees(Constants.rotationAnge))
                    .font(.system(size: Constants.dotsImageFont))
                    .foregroundStyle(.darkGray)
            }
        }
    }
}

private extension FriendsManagementView {
    var requestsListView: some View {
        VStack(spacing: Constants.allRequestsSpacing) {
            ForEach(viewModel.visibleRequests, id: \.self) { person in
                friendRequestView(person: person)
            }
        }
    }
}

private extension FriendsManagementView {
    func buttonWithoutBackground(title: LocalizedStringResource, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(color)
                .font(.system(size: Constants.buttonTextFontSize, weight: .semibold))
        }
    }
    
    func countView(count: Int) -> some View {
        Text(String(count))
            .foregroundStyle(.darkPink)
            .font(.system(size: Constants.countViewFontSize, weight: .bold))
            .padding(Constants.countViewPadding)
            .background {
                Circle()
                    .foregroundStyle(.lightPink)
                    .opacity(Constants.countViewBackgroundOpacity)
            }
    }
}

private extension FriendsManagementView {
    func friendRequestView(person: FriendModel) -> some View {
        VStack(alignment: .leading, spacing: Constants.requestVerticalSpacing) {
            HStack(alignment: .center) {
                PersonAvatarView(firstLetter: viewModel.avatarFirstLetter(friend: person), avatarPath: viewModel.getAvatarUrl(forImage: person.avatarPath))
                
                VStack(alignment: .leading) {
                    Text(person.name)
                        .foregroundStyle(.black)
                        .font(.system(size: Constants.requestFontSize, weight: .bold))
                    
                    Text(person.timestamp, style: .relative)
                        .font(.system(size: Constants.requestFontSize, weight: .medium))
                }
            }
            
            buttonsView(person: person)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: Constants.requestCornerRadius)
                .foregroundStyle(.white)
        }
    }
    
    func buttonsView(person: FriendModel) -> some View {
        HStack(spacing: Constants.requestButtonsSpacing) {
            capsuleButton(
                caption: LocalizedStringResource.accept,
                color: Gradients.pinkGradient,
                textColor: .white,
                action: { viewModel.acceptInvite(person: person) }
            )
            
            capsuleButton(
                caption: LocalizedStringResource.decline,
                color: .lightGray,
                textColor: .darkGray,
                action: { viewModel.declineInvite(person: person) }
            )
        }
    }
    
    func capsuleButton<Style: ShapeStyle>(
        caption: LocalizedStringResource,
        color: Style,
        textColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(caption)
                .foregroundStyle(textColor)
                .font(.system(size: Constants.requestButtonFontSize, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.requestButtonVerticalPadding)
                .background {
                    Capsule()
                        .foregroundStyle(color)
                }
        }
    }
}

private extension FriendsManagementView {
    var findFriendsSection: some View {
        VStack(spacing: Constants.findFriendSectionSpacing) {
            Text(.growYourSquad)
                .font(.system(size: Constants.titleFontSize, weight: .bold))
                .foregroundStyle(.white)
            
            Text(.findPeopleNeabyOrInviteYourWorldContacts)
                .multilineTextAlignment(.center)
                .font(.system(size: Constants.captionFontSize, weight: .medium))
                .foregroundStyle(.lightGray)
            
            Button(action: { coordinator.push(route: .findUsers) } ) {
                HStack(spacing: Constants.findFriendsSpacing) {
                    Text(.addFriends)
                    
                    Image(systemName: Assets.personPlus)
                }
                .font(.system(size: Constants.findFriendButtonFont, weight: .bold))
                .foregroundStyle(.darkPink)
                .padding(.vertical)
                .padding(.horizontal, Constants.findFriendsHorizontalPadding)
                .background {
                    Capsule()
                        .foregroundStyle(.white)
                        .shadow(
                            color: .black.opacity(Constants.shadowOpacity),
                            radius: Constants.shadowRadius,
                            x: Constants.shadowDirection,
                            y: Constants.shadowDirection
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.friendSectionPadding)
        .background {
            RoundedRectangle(cornerRadius: Constants.findSectionCornerRadius)
                .foregroundStyle(Gradients.pinkGradient)
                .shadow(
                    color: .darkPink.opacity(Constants.shadowOpacity),
                    radius: Constants.shadowRadius,
                    x: Constants.shadowDirection,
                    y: Constants.shadowDirection
                )
        }
    }
}

private extension FriendsManagementView {
    enum Constants {
        static let mainViewSpacing: CGFloat = 30
        static let scrollViewSpacing: CGFloat = 20
        static let headerHorizontalPadding: CGFloat = 10
        static let blurRadius: CGFloat = 20
        static let friendsSpacing: CGFloat = 22
        static let friendsCornerRadius: CGFloat = 45
        static let friendViewHorizontalSpacing: CGFloat = 10
        static let friendViewVerticalSpacing: CGFloat = 6
        static let friendViewFontSize: CGFloat = 19
        static let dotsImageFont: CGFloat = 25
        static let rotationAnge: CGFloat = 90
        static let allRequestsSpacing: CGFloat = 20
        static let buttonTextFontSize: CGFloat = 19
        static let countViewFontSize: CGFloat = 23
        static let countViewPadding: CGFloat = 10
        static let countViewBackgroundOpacity: CGFloat = 0.3
        static let requestVerticalSpacing: CGFloat = 20
        static let requestFontSize: CGFloat = 19
        static let requestCornerRadius: CGFloat = 35
        static let requestButtonsSpacing: CGFloat = 20
        static let requestButtonFontSize: CGFloat = 20
        static let requestButtonVerticalPadding: CGFloat = 10
        static let findFriendSectionSpacing: CGFloat = 20
        static let titleFontSize: CGFloat = 33
        static let captionFontSize: CGFloat = 18
        static let findFriendsSpacing: CGFloat = 10
        static let findFriendButtonFont: CGFloat = 24
        static let findFriendsHorizontalPadding: CGFloat = 30
        static let shadowOpacity: CGFloat = 0.15
        static let shadowRadius: CGFloat = 5
        static let shadowDirection: CGFloat = 6
        static let friendSectionPadding: CGFloat = 40
        static let findSectionCornerRadius: CGFloat = 40
    }
}

private extension FriendsManagementView {
    enum Assets {
        static let personPlus = "person.crop.circle.badge.plus"
        static let dots = "ellipsis"
    }
}
