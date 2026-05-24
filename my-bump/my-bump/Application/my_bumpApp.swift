//
//  my_bumpApp.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 13.04.26.
//

import SwiftUI
import FirebaseCore

@main
struct my_bumpApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
