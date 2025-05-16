import Foundation
import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingFollowers = false
    @State private var showingFollowing = false

    var followers: [String] = ["fashionqueen", "styleking", "modaguru"]
    var following: [String] = ["olga", "runwaypro", "dailylook"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Фото и имя
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        Text("@username")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding(.top)

                    // Статистика
                    HStack(spacing: 40) {
                        VStack {
                            Text("24")
                                .font(.headline)
                            Text("Аутфита")
                                .font(.caption)
                        }
                        VStack {
                            Button(action: {
                                showingFollowers = true
                            }) {
                                VStack {
                                    Text("120")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text("Подписчики")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        VStack {
                            Button(action: {
                                showingFollowing = true
                            }) {
                                VStack {
                                    Text("120")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text("Подписки")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)

                    Divider()

                    // Сетка публикаций — 2 в ряд
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(0..<12, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Выйти")
                }
            }
            .sheet(isPresented: $showingFollowers) {
                UserListView(title: "Подписчики", users: followers)
            }
            .sheet(isPresented: $showingFollowing) {
                UserListView(title: "Подписки", users: following)
            }
        }
    }
}


struct UserListView: View {
    let title: String
    let users: [String]

    var body: some View {
        NavigationView {
            List(users, id: \.self) { user in
                NavigationLink(destination: OtherUserProfileView(username: user)) {
                    Text("@" + user)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct OtherUserProfileView: View {
    let username: String

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                Text("@\(username)")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Это публичный профиль пользователя \(username).")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()

                Divider()

                Text("Публикации")
                    .font(.headline)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(0..<6, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("@\(username)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
