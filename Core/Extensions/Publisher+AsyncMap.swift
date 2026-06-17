//
//  Combine+AsyncMap.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 8.06.26.
//

import Combine

extension Publisher {
    func asyncMap<T>(_ transform: @escaping (Output) async -> T) -> AnyPublisher<T, Failure> {
        flatMap { output in
            Future<T, Failure> { promise in
                Task {
                    let result = await transform(output)
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
