//
//  SectionView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import SwiftUI

struct FriendsSectionView<
    AdditionalLeadingContent: View,
    AdditionalTrailingContent: View,
    MainConent: View>: View {
    
    private let title: LocalizedStringResource
    private let leadingContent: AdditionalLeadingContent?
    private let trailingContent: AdditionalTrailingContent?
    private let mainContent: MainConent
    
    init(
        title: LocalizedStringResource,
        leadingContent: AdditionalLeadingContent? = EmptyView(),
        trailingContent: AdditionalTrailingContent? = EmptyView(),
        mainContent: MainConent
    ) {
        self.title = title
        self.leadingContent = leadingContent
        self.trailingContent = trailingContent
        self.mainContent = mainContent
    }
    
    var body: some View {
        VStack(spacing: Constants.verticalSpacing) {
            HStack(alignment: .center, spacing: Constants.horizontalSpacing) {
                Text(title)
                    .font(.system(size: Constants.titleFontSize, weight: .bold))
                    .foregroundStyle(.black)
                
                leadingContent
                
                Spacer()
                
                trailingContent
            }
            
            mainContent
        }
    }
}

private extension FriendsSectionView {
    enum Constants {
        static var verticalSpacing: CGFloat { 10 }
        static var horizontalSpacing: CGFloat { 5 }
        static var titleFontSize: CGFloat { 27 }
    }
}
