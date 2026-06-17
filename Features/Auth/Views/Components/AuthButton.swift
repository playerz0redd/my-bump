//
//  AuthButton.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.04.26.
//

import Foundation
import SwiftUI

struct AuthButton: View {
    
    private let title: LocalizedStringResource
    private let action: () -> Void
    
    init(title: LocalizedStringResource, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Constants.errorTitleFontSize, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.textVerticalPadding)
                .foregroundStyle(.white)
                .background {
                    Capsule()
                        .foregroundStyle(.pink.gradient)
                        .shadow(
                            color: .pink.opacity(Constants.shadowColorOpacity),
                            radius: Constants.shadowRadius,
                            x: Constants.shadowX,
                            y: Constants.shadowY
                        )
                }
        }
    }
}

private extension AuthButton {
    enum Constants {
        static let errorTitleFontSize: CGFloat = 23
        static let textVerticalPadding: CGFloat = 15
        static let shadowColorOpacity: CGFloat = 0.15
        static let shadowRadius: CGFloat = 10
        static let shadowX: CGFloat = 7
        static let shadowY: CGFloat = 7
    }
}
