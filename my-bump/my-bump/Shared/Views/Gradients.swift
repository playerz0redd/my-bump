//
//  Gradients.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import SwiftUI

enum Gradients {
    static var pinkGradient: LinearGradient {
        LinearGradient(
            colors: [.darkPink, .lightPink],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [.pink.opacity(0.2), .blue.opacity(0.2)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
