//
//  LocalUserService.swift
//  AIChat
//
//  Created by macbook on 18.05.2026.
//

import Foundation

protocol LocalUserService {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(_ user: UserModel?) throws
}
