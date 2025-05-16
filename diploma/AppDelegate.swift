//
//  AppDelegate.swift
//  diploma
//
//  Created by Olga on 09.05.2025.
//


import Foundation
import PostHog
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let POSTHOG_API_KEY = "phc_slQtAstXzwEgxa2q7vF4SejI2xwOXsbcHRasJF4xFiL"
        let POSTHOG_HOST = "https://eu.i.posthog.com"

        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)

        config.captureApplicationLifecycleEvents = true

        PostHogSDK.shared.setup(config)

        logger.info("🚀 PostHog initialized via AppDelegate.")

        return true
    }
}
