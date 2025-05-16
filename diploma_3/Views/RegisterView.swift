//
//  RegisterView.swift
//  diploma
//
//  Created by Olga on 13.04.2025.
//

import Foundation
import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Электронная почта")) {
                    TextField("email@example.com", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                Section(header: Text("Пароль")) {
                    SecureField("Пароль", text: $viewModel.password)
                    SecureField("Повторите пароль", text: $viewModel.confirmPassword)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Зарегистрироваться") {
                    viewModel.register()
                }
            }
            .navigationTitle("Регистрация")
            .onChange(of: viewModel.registrationSuccess) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
