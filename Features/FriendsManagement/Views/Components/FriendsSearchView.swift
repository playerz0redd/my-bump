//
//  FriendsSearchView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import SwiftUI

struct FriendsSearchView: View {
    
    private let text: Binding<String>
    private let caption: LocalizedStringResource
    
    init(text: Binding<String>, caption: LocalizedStringResource) {
        self.text = text
        self.caption = caption
    }
    
    var body: some View {
        HStack {
            Image(systemName: Constants.magnifyIcon)
            
            TextField("", text: text, prompt: Text(caption))
        }
        .frame(maxWidth: .infinity)
        .font(.system(size: Constants.fontSize, weight: .medium))
        .foregroundStyle(.darkGray)
        .padding(.vertical, Constants.verticalPadding)
        .padding(.horizontal, Constants.horizontalPadding)
        .background {
            Capsule()
                .foregroundStyle(.white.opacity(Constants.foregroundOpacity))
        }
    }
}

private extension FriendsSearchView {
    enum Constants {
        static let fontSize: CGFloat = 20
        static let verticalPadding: CGFloat = 13
        static let horizontalPadding: CGFloat = 20
        static let foregroundOpacity: CGFloat = 0.7
        static let magnifyIcon: String = "magnifyingglass"
    }
}
