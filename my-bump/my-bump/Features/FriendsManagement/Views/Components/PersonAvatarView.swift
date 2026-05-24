//
//  PersonAvatar.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import SwiftUI
import Kingfisher

struct PersonAvatarView: View {
    
    private let firstLetter: String
    private let avatarPath: URL?
    
    init(firstLetter: String, avatarPath: URL?) {
        self.firstLetter = firstLetter
        self.avatarPath = avatarPath
    }
    
    var body: some View {
        ZStack {
            if let path = avatarPath {
                KFImage(path)
                    .resizable()
                    .placeholder {
                        ProgressView()
                            .progressViewStyle(.automatic)
                    }
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Text(firstLetter.uppercased())
                    .font(.system(size: Constants.fontSize, weight: .bold))
                    .foregroundStyle(.lightGray)
                    .padding(Constants.padding)
                    .background {
                        Circle()
                            .foregroundStyle(.lightPink)
                    }
            }
        }
        .frame(width: 50, height: 50)
    }
}

private extension PersonAvatarView {
    enum Constants {
        static let fontSize: CGFloat = 27
        static let padding: CGFloat = 13
    }
}
