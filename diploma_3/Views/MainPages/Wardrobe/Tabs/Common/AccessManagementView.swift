//
//  AccessManagementView.swift
//  diploma
//
//  Created by Olga on 21.04.2025.
//

import SwiftUI

struct AccessManagementView: View {
    let wardrobeId: Int
    @State private var shareNickname = ""
    @State private var selectedAccessLevel: AccessLevel = .view
    @State private var accessList: [SharedAccess] = []
    
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Дать доступ")) {
                    TextField("Никнейм пользователя", text: $shareNickname)

                    Picker("Уровень доступа", selection: $selectedAccessLevel) {
                        ForEach(AccessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized)
                        }
                    }

                    Button("Поделиться") {
                        let dummyUserId = 5

                        WardrobeService.shared.grantAccess(
                            wardrobeId: wardrobeId,
                            grantedToUserId: dummyUserId,
                            accessType: selectedAccessLevel.rawValue
                        ) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    showSuccessAlert = true
                                    shareNickname = ""
                                    fetchAccessList()
                                case .failure:
                                    showErrorAlert = true
                                }
                            }
                        }
                    }
                    .disabled(shareNickname.isEmpty)
                }

                Section(header: Text("Текущие доступы")) {
                    if accessList.isEmpty {
                        Text("Нет выданных доступов")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(accessList, id: \.id) { access in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Пользователь ID: \(access.grantedToUserId)")
                                    Text("Доступ: \(access.accessType)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button(role: .destructive) {
                                    revokeAccess(access)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Управление доступом")
            .onAppear {
                fetchAccessList()
            }
            .alert("Доступ выдан", isPresented: $showSuccessAlert) {
                Button("Ок", role: .cancel) { }
            }
            .alert("Ошибка", isPresented: $showErrorAlert) {
                Button("Ок", role: .cancel) { }
            }
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
