//
//  AppRootView.swift
//  diploma
//
//  Created by Olga on 13.04.2025.
//

import SwiftUI
import Foundation

struct AppRootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @ObservedObject private var tokenManager = TokenManager.shared

    var body: some View {
        Group {
            if tokenManager.sessionExpired {
                SessionExpiredView {
                    tokenManager.stopMonitoring()
                    authViewModel.logout()
                }
            } else if authViewModel.isAuthenticated {
                WeeklyCalendarView()
                    .environmentObject(authViewModel)
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
        .onAppear {
            if let token = KeychainHelper.get(forKey: "accessToken") {
                print("Найден токен: \(token)")

                if let expDate = JWTDecoder.decodeExpiration(from: token) {
                    if expDate > Date() {
                        print("Токен действителен до \(expDate)")
                        authViewModel.isAuthenticated = true
                        TokenManager.shared.startMonitoring(token: token)
                    } else {
                        print("Токен истёк \(expDate)")
                        authViewModel.logout()
                    }
                } else {
                    print("Ошибка декодирования токена")
                    authViewModel.logout()
                }
            }
        }
    }
}
