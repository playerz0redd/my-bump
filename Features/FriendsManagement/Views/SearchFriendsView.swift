//
//  SearchFriendsView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import SwiftUI

struct SearchFriendsView: View {
    
    @Bindable private var viewModel: FriendsManagementViewModel
    
    init(viewModel: FriendsManagementViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                
                HeaderView(firstNameLetter: "P")
                    .padding(.horizontal, Constants.headerHorizontalPadding)
                    .padding(.bottom)
                
                VStack(spacing: Constants.friendsSectionSpacing) {
                    FriendsSearchView(text: $viewModel.searchPeopleText, caption: LocalizedStringResource.findExplorersByUsername)
                    
                    FriendsSectionView(title: LocalizedStringResource.suggestions, trailingContent: trendingView, mainContent: peopleView)
                }
                .padding(.horizontal)
            }
        }
        .background {
            Gradients.backgroundGradient
                .ignoresSafeArea()
        }
        .onAppear(perform: viewModel.fetchUsersByName)
    }
}

private extension SearchFriendsView {
    @ViewBuilder
    func getViewByRelation(relation: FriendStatus, person: FriendModel) -> some View {
        switch relation {
        case .requesting:
            Text(.requesting)
        case .responsing:
            Text(.responsing)
        case .friends:
            Text(.friends)
        case .block:
            Text(.blocked)
        case .unknown, .removeFriend:
            addFriendButton(person: person)
        }
    }
}

private extension SearchFriendsView {
    var peopleView: some View {
        VStack(spacing: Constants.personSpacing) {
            ForEach(viewModel.searchUsers, id: \.self) { person in
                personView(person: person)
            }
        }
        .animation(.bouncy, value: viewModel.searchUsers)
    }
}

private extension SearchFriendsView {
    func addFriendButton(person: FriendModel) -> some View {
        Button(action: { viewModel.addToFriends(person: person) }) {
            Text(.add)
                .font(.system(size: Constants.addFriendButtonTextFont, weight: .bold))
                .foregroundStyle(.white)
                .padding(.vertical, Constants.addFriendButtonVerticalPadding)
                .padding(.horizontal, Constants.addFriendButtonHorizontalPadding)
                .background {
                    Capsule()
                        .foregroundStyle(Gradients.pinkGradient)
                }
        }
    }
}

private extension SearchFriendsView {
    func personView(person: FriendModel) -> some View {
        HStack(spacing: Constants.personViewSpacing) {
            PersonAvatarView(firstLetter: String(person.name.prefix(1)), avatarPath: viewModel.getAvatarUrl(forImage: person.avatarPath))
            
            Text(person.name)
                .font(.system(size: Constants.personNameTextFont, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            getViewByRelation(relation: person.status, person: person)
                .foregroundStyle(Gradients.pinkGradient)
                .font(.system(size: Constants.statusTextFont, weight: .semibold))
        }
        .padding()
        .background {
            Capsule()
                .foregroundStyle(.white)
        }
        .animation(.bouncy, value: viewModel.requesting)
    }
}

private extension SearchFriendsView {
    var trendingView: some View {
        HStack {
            Circle()
                .frame(width: Constants.trendingCircleSize, height: Constants.trendingCircleSize)
            
            Text(.trending)
                .font(.system(size: Constants.trendingTextFont, weight: .semibold))
        }
        .foregroundStyle(.darkGray)
        .padding(.vertical, Constants.trendingVerticalPadding)
        .padding(.horizontal, Constants.trendingHorizontalPadding)
        .background {
            Capsule()
                .foregroundStyle(.lightGreen)
        }
    }
}

private extension SearchFriendsView {
    enum Constants {
        static let headerHorizontalPadding: CGFloat = 10
        static let friendsSectionSpacing: CGFloat = 20
        static let personSpacing: CGFloat = 15
        static let addFriendButtonTextFont: CGFloat = 22
        static let addFriendButtonVerticalPadding: CGFloat = 9
        static let addFriendButtonHorizontalPadding: CGFloat = 13
        static let personViewSpacing: CGFloat = 7
        static let personNameTextFont: CGFloat = 22
        static let statusTextFont: CGFloat = 19
        static let trendingCircleSize: CGFloat = 5
        static let trendingTextFont: CGFloat = 18
        static let trendingVerticalPadding: CGFloat = 6
        static let trendingHorizontalPadding: CGFloat = 10
    }
}
