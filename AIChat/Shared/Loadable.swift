//
//  Loadable.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 17.07.2026.
//

import Foundation

enum Loadable<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    var value: Value? {
        guard case let .loaded(value) = self
        else {
            return nil
        }
        return value
    }

    var errorMessage: String? {
        guard case let .failed(message) = self
        else {
            return nil
        }
        return message
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

extension Loadable where Value: RangeReplaceableCollection {
    var valueOrEmpty: Value {
        value ?? .init()
    }
}
