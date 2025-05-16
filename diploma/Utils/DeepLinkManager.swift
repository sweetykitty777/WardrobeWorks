//
//  DeepLinkManager.swift
//  diploma
//
//  Created by Olga on 11.05.2025.
//

import Foundation
import SwiftUI

class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()

    @Published var resetPasswordToken: String?

    func handle(url: URL) {
        guard url.scheme == "wardrobeworks" else {
            print("Unsupported scheme: \(url.scheme ?? "nil")")
            return
        }

        if url.host == "reset-password",
           let token = url.queryParameters["token"] {
            print("Получен токен для сброса пароля: \(token)")
            resetPasswordToken = token
        } else {
            print("Неизвестный deep link: \(url)")
        }
    }
}

extension URL {
    var queryParameters: [String: String] {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [:]) { $0[$1.name] = $1.value } ?? [:]
    }
}
