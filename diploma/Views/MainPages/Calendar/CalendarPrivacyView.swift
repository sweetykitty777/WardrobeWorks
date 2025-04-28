//
//  CalendarPrivacyView.swift
//  diploma
//
//  Created by Olga on 27.04.2025.
//

import Foundation
import SwiftUI

struct CalendarPrivacyView: View {
    @ObservedObject var viewModel: CalendarPrivacyViewModel

    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $viewModel.isPrivate) {
                    Text(viewModel.isPrivate ? "Приватный календарь" : "Публичный календарь")
                        .fontWeight(.medium)
                }
                .onChange(of: viewModel.isPrivate) { _ in
                    viewModel.changePrivacy()
                }
            }
            .navigationTitle("Приватность")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                toastOverlay,
                alignment: .top
            )
        }
    }

    private var toastOverlay: some View {
        Group {
            if viewModel.showToast {
                Text(viewModel.toastMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(viewModel.toastColor)
                    .cornerRadius(12)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { viewModel.showToast = false }
                        }
                    }
            }
        }
    }
}
