import SwiftUI
import os

struct AppRootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @ObservedObject private var tokenManager = TokenManager.shared
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var didPreload = false

    var body: some View {
        NavigationStack {
            Group {
                if let token = deepLinkManager.resetPasswordToken {
                    ResetPasswordView(token: token) {
                        deepLinkManager.resetPasswordToken = nil
                    }


                } else if tokenManager.sessionExpired {
                    SessionExpiredView {
                        tokenManager.stopMonitoring()
                        authViewModel.logout()
                    }


                } else if authViewModel.isAuthenticated {
                    WeeklyCalendarView()
                        .environmentObject(authViewModel)
                        .onAppear {
                            if !didPreload {
                                // PreloadManager.shared.preloadResources()
                                didPreload = true
                            }
                        }

                // Не авторизован
                } else {
                    AuthView(viewModel: authViewModel)
                }
            }
            .applyNavigationRouter()
        }
        .onAppear {
            logger.info("AppRootView appeared. Logging initialized.")
            authViewModel.checkExistingToken()
        }
    }
}
