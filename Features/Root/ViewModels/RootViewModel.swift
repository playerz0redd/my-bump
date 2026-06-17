//
//  RootViewModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation
import Observation
import Combine

@MainActor @Observable
final class RootViewModel {
    var cancellables: Set<AnyCancellable> = []
}
