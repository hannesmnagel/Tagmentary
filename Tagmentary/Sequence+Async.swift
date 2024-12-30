//
//  Sequence+Async.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/27/24.
//

import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
