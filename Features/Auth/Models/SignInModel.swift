//
//  SignInModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 15.04.26.
//

import Foundation

struct SignInModel: Equatable {
    var email: String
    var password: String
}

extension SignInModel {
    init() {
        self.email = ""
        self.password = ""
    }
}
