import SwiftUI

struct AccessManagementView: View {
    let wardrobeId: Int
    @StateObject private var searchViewModel = UserCalendarSearchViewModel()
    
    @State private var selectedUser: UserProfile? = nil
    @State private var selectedAccessLevel: AccessLevel = .view
    @State private var accessList: [SharedAccess] = []
    
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Выдать доступ")) {
                    TextField("Введите ник пользователя...", text: $searchViewModel.searchText, onCommit: {
                        searchViewModel.searchUsers()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 4)
                    .submitLabel(.search)

                    if !searchViewModel.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(searchViewModel.searchResults) { user in
                                    Button(action: {
                                        selectedUser = user
                                        searchViewModel.searchResults = []
                                        searchViewModel.searchText = ""
                                    }) {
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
                            .padding(.top, 4)
                        }
                        .frame(height: 150)
                    }

                    if let user = selectedUser {
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
                        .padding(.vertical, 6)
                    }

                    Picker("Уровень доступа", selection: $selectedAccessLevel) {
                        ForEach(AccessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 4)

                    Button(action: {
                        guard let user = selectedUser else { return }

                        WardrobeService.shared.grantAccess(
                            wardrobeId: wardrobeId,
                            grantedToUserId: user.id,
                            accessType: selectedAccessLevel.rawValue
                        ) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    showSuccessAlert = true
                                    selectedUser = nil
                                    fetchAccessList()
                                case .failure:
                                    showErrorAlert = true
                                }
                            }
                        }
                    }) {
                        Text("Поделиться")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedUser == nil ? Color.gray.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(selectedUser == nil)
                }

                Section(header: Text("Текущие доступы")) {
                    if accessList.isEmpty {
                        Text("Нет выданных доступов")
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(accessList, id: \.id) { access in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("ID: \(access.grantedToUserId)")
                                        .font(.body)
                                    Text("Доступ: \(access.accessType)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button(role: .destructive) {
                                    revokeAccess(access)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .background(Color.white)
        }
        .navigationTitle("Управление доступом")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchAccessList()
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(title: Text("Успех"), message: Text("Доступ выдан"), dismissButton: .default(Text("Ок")))
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Ошибка"), message: Text("Не удалось выдать доступ"), dismissButton: .default(Text("Ок")))
        }
    }

    private func fetchAccessList() {
        WardrobeService.shared.fetchAccessList { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    accessList = list.filter { $0.wardrobeId == wardrobeId }
                case .failure(let error):
                    print("Ошибка загрузки доступов: \(error)")
                }
            }
        }
    }

    private func revokeAccess(_ access: SharedAccess) {
        WardrobeService.shared.revokeAccess(accessId: access.id) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    accessList.removeAll { $0.id == access.id }
                }
            }
        }
    }
}
