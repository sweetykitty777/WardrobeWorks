import Foundation
import SwiftUI

enum AccessLevel: String, Codable, CaseIterable {
    case view = "view"
    case edit = "edit"
}

struct ShareAccessView: View {
    @StateObject var viewModel: ShareAccessViewModel
    @State private var selectedAccess: AccessLevel = .view

    var body: some View {
        VStack(spacing: 16) {
            Text("Поделиться доступом")
                .font(.title2)
                .fontWeight(.semibold)

            TextField("Введите никнейм пользователя", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onSubmit {
                    viewModel.searchUsers()
                }

            if !viewModel.searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.searchResults) { user in
                            Button {
                                viewModel.selectedUser = user
                                viewModel.searchText = user.username
                                viewModel.searchResults = []
                            } label: {
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
                    .padding(.horizontal)
                }
                .frame(maxHeight: 150)
            }

            if let selected = viewModel.selectedUser {
                VStack(spacing: 12) {
                    HStack {
                        if let avatar = selected.avatar {
                            RemoteImageView(urlString: avatar, cornerRadius: 20, width: 40, height: 40)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                        VStack(alignment: .leading) {
                            Text("@\(selected.username)")
                                .fontWeight(.bold)
                            if let bio = selected.bio {
                                Text(bio)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    Picker("Уровень доступа", selection: $selectedAccess) {
                        ForEach(AccessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized)
                                .tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.addSharedAccess(level: selectedAccess)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Выдать доступ")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }

            Divider()
                .padding(.vertical, 8)

            List {
                ForEach(viewModel.sharedAccesses) { access in
                    HStack(spacing: 12) {
                        if let user = viewModel.userProfilesById[access.grantedToUserId] {
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
                                Text("Доступ: \(access.accessType.capitalized)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        } else {
                            VStack(alignment: .leading) {
                                Text("ИД пользователя: \(access.grantedToUserId)")
                                    .fontWeight(.semibold)
                                Text("Доступ: \(access.accessType.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.removeSharedAccess)
            }
            .listStyle(InsetGroupedListStyle())

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .padding(.top)
        .navigationTitle("Доступ к гардеробу")
        .navigationBarTitleDisplayMode(.inline)
    }
}
