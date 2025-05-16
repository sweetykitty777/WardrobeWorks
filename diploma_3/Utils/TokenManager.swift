//
//  TokenManager.swift
//  diploma
//
//  Created by Olga on 13.04.2025.
//

import Foundation
import Combine

class TokenManager: ObservableObject {
    static let shared = TokenManager()

    @Published var sessionExpired: Bool = false
    private var expirationDate: Date?
    private var timer: Timer?

    private init() {}

    func startMonitoring(token: String) {
        stopMonitoring()

        guard let expDate = JWTDecoder.decodeExpiration(from: token) else {
            print("Невозможно извлечь дату")
            sessionExpired = true
            return
        }

        expirationDate = expDate
        let interval = expDate.timeIntervalSinceNow

        if interval > 0 {
            print("Сессия истекает через \(Int(interval)) секунд")
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                print("Токен истёк")
                self.sessionExpired = true
            }
        } else {
            sessionExpired = true
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        sessionExpired = false
        expirationDate = nil
    }
}
