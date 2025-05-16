//
//  SocialService.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

final class SocialService {
    static let shared = SocialService()
    let api = ApiClient.shared

    private init() {}
}
