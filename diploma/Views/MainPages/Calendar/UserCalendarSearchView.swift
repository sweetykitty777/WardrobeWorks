//
//  UserCalendarSearchView.swift
//  diploma
//
//  Created by Olga on 27.04.2025.
//

import Foundation
import SwiftUI

struct UserCalendarSearchView: View {
    @StateObject private var viewModel = UserCalendarSearchViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Поисковая строка
                TextField("Поиск пользователей...", text: $viewModel.searchText, onCommit: {
                    viewModel.searchUsers()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .submitLabel(.search)
                
                if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    Text("Нет результатов")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { user in
                                NavigationLink(destination: UserCalendarView(userId: user.id)) {
                                    HStack {
                                        if let avatar = user.avatar {
                                            RemoteImageView(urlString: avatar, cornerRadius: 20, width: 40, height: 40)
                                        } else {
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        }
                                        VStack(alignment: .leading) {
                                            Text("@\(user.username)")
                                                .fontWeight(.semibold)
                                            if let bio = user.bio {
                                                Text(bio)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Найти пользователя")
            .onChange(of: viewModel.searchText) { newValue in
                if newValue.isEmpty {
                    viewModel.clearResults()
                }
            }
        }
    }
}
