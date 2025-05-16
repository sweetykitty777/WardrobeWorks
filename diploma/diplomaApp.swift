//
//  diplomaApp.swift
//  diploma
//
//  Created by Olga on 05.01.2025.
//

import SwiftUI
import PostHog

@main
struct diplomaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var deepLinkManager = DeepLinkManager()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(deepLinkManager)
                .onOpenURL { url in
                    deepLinkManager.handle(url: url)
                }
        }
    }
}
