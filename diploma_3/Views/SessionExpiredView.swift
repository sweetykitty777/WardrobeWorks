//
//  SessionExpiredView.swift
//  diploma
//
//  Created by Olga on 13.04.2025.
//

import Foundation
import SwiftUI

struct SessionExpiredView: View {
    var onReLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)

            Text("Сессия истекла")
                .font(.title)
                .fontWeight(.bold)

            Text("Пожалуйста, войдите в аккаунт заново.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button(action: {
                onReLogin()
            }) {
                Text("Войти снова")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

