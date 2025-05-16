//
//  ShareAccessViewModel.swift
//  diploma
//
//  Created by Olga on 21.04.2025.
//

import Foundation
import Combine

@MainActor
class ShareAccessViewModel: ObservableObject {
    @Published var sharedAccesses: [SharedAccess] = []
    @Published var errorMessage: String?

    private let wardrobeId: Int

    init(wardrobeId: Int) {
        self.wardrobeId = wardrobeId
        loadSharedAccesses()
    }

    func loadSharedAccesses() {
        WardrobeService.shared.fetchAccessList { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accesses):
                    self?.sharedAccesses = accesses.filter { $0.wardrobeId == self?.wardrobeId }
                case .failure(let error):
                    self?.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                }
            }
        }
    }

    func addSharedAccess(nickname: String, level: AccessLevel) {
        // Здесь тебе нужно как-то найти `grantedToUserId` по никнейму
        // Пока заглушка
        let dummyUserId = findUserIdByNickname(nickname)
        
        // 🪪 Лог перед отправкой
        let payload = [
            "wardrobeId": wardrobeId,
            "grantedToUserId": dummyUserId,
            "accessType": level.rawValue
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🚀 Grant access payload:\n\(jsonString)")
        } else {
            print("⚠️ Не удалось сериализовать grant access payload")
        }

        // Вызов API
        WardrobeService.shared.grantAccess(
            wardrobeId: wardrobeId,
            grantedToUserId: dummyUserId,
            accessType: level.rawValue
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadSharedAccesses()
                case .failure(let error):
                    self?.errorMessage = "Ошибка выдачи доступа: \(error.localizedDescription)"
                    print("❌ Ошибка grantAccess: \(error)")
                }
            }
        }
    }

    func removeSharedAccess(at offsets: IndexSet) {
        for index in offsets {
            let access = sharedAccesses[index]
            WardrobeService.shared.revokeAccess(accessId: access.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.sharedAccesses.remove(at: index)
                    case .failure(let error):
                        self?.errorMessage = "Ошибка удаления доступа: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    private func findUserIdByNickname(_ nickname: String) -> Int {
        // TODO: Сделай реальный поиск по юзернейму (никнейму)
        // Например, через ручку: /user/by-nickname/{nickname}
        // Пока вернём заглушку
        return 5
    }
}

