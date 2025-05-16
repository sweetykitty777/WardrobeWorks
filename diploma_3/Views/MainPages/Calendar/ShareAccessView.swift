//
//  ShareAccessView.swift
//  diploma
//
//  Created by Olga on 21.04.2025.
//

import Foundation
import SwiftUI

enum AccessLevel: String, Codable, CaseIterable {
    case view = "view"
    case edit = "edit"
}

struct ShareAccessView: View {
    @StateObject var viewModel: ShareAccessViewModel
    @State private var nickname = ""
    @State private var selectedAccess: AccessLevel = .view

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Поделиться доступом")
                    .font(.title2)
                    .fontWeight(.semibold)

                TextField("Введите никнейм", text: $nickname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Picker("Уровень доступа", selection: $selectedAccess) {
                    ForEach(AccessLevel.allCases, id: \.self) { level in
                        Text(level.rawValue.capitalized).tag(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                Button(action: {
                    guard !nickname.isEmpty else { return }
                    viewModel.addSharedAccess(nickname: nickname, level: selectedAccess)
                    nickname = ""
                    selectedAccess = .view
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                Divider().padding(.vertical, 8)

                List {
                    ForEach(viewModel.sharedAccesses) { access in
                        HStack {
                            Text("User ID: \(access.grantedToUserId)")
                            Spacer()
                            Text(access.accessType.capitalized)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: viewModel.removeSharedAccess)
                }

                if let error = viewModel.errorMessage {
                    Text(" \(error)")
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
            }
            .padding(.top)
            .navigationBarTitle("Доступ к гардеробу", displayMode: .inline)
        }
    }
}
