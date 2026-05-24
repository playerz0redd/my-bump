//
//  AuthErrorView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.04.26.
//

import Foundation
import SwiftUI

struct AuthErrorView: View {
    let authError: AuthServiceError?
    
    var body: some View {
        if let error = authError {
            Text(error.message)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }
}
