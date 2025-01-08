//
//  Binding + EXT.swift
//  AIChat
//
//  Created by macbook on 08.01.2025.
//
import SwiftUI

extension Binding where Value == Bool {
    
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}

