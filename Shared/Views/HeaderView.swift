//
//  HeaderView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import SwiftUI

struct HeaderView: View {
    
    private let firstNameLetter: String
    
    init(firstNameLetter: String) {
        self.firstNameLetter = firstNameLetter
    }
    
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 34))
            
            Text(.neonPlayground)
                .font(.system(size: 28, weight: .bold))
                .italic()
            
            Spacer()
            
            Text(firstNameLetter)
                .font(.system(size: 34, weight: .semibold))
                .padding(14)
                .background {
                    Circle()
                        .foregroundStyle(.orange.gradient)
                }
        }
        .foregroundStyle(Gradients.pinkGradient)
        .padding(.vertical, 5)
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity)
        .background {
            Capsule()
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 7, y: 7)
        }
        
    }
}
