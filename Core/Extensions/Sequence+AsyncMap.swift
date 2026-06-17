//
//  Sequence+AsyncMap.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation


extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values: [T] = []
        for element in self {
            values.append(try await transform(element))
        }
        return values
    }
    
    func concurrentMap<T>(_ transform: @escaping (Element) async throws -> T?) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: (Int, T?).self) { group in
            for (index, element) in self.enumerated() {
                group.addTask {
                    let value = try await transform(element)
                    return (index, value)
                }
            }
            
            var results: [Int: T] = [:]
            
            for try await result in group {
                guard let value = result.1 else { continue }
                results[result.0] = value
            }
            return results.sorted(by: { $0.key < $1.key }).map(\.value)
        }
    }
}
