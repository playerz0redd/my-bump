//
//  SignUpModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.04.26.
//

import Foundation

struct SignUpModel: Equatable {
    var name: String
    var email: String
    var password: String
    var confirmPassword: String
}

extension SignUpModel {
    init() {
        self.name = ""
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
    }
}
