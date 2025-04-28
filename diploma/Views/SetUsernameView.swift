//
//  SetUsernameView.swift
//  diploma
//
//  Created by Olga on 25.04.2025.
//

import Foundation
import SwiftUI

struct SetUsernameView: View {
    @ObservedObject var viewModel = SetUsernameViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Новый никнейм")) {
                    TextField("Введите никнейм", text: $viewModel.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button {
                        viewModel.setUsername()
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Сохранить")
                            }
                        }
                    }
                    .disabled(viewModel.username.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Установить никнейм")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: viewModel.success) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
