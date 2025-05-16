//
//  WardrobeViewModel.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation

class WardrobeViewModel: ObservableObject {
    @Published var wardrobes: [UsersWardrobe] = []
    @Published var selectedWardrobe: UsersWardrobe?

    func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    self.wardrobes = wardrobes
                case .failure(let error):
                    print("❌ Ошибка загрузки: \(error)")
                }
            }
        }
    }

    func fetchWardrobes(of userId: Int) {
        WardrobeService.shared.getWardrobes(of: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.wardrobes = list
                case .failure(let error):
                    print("❌ Ошибка загрузки чужих гардеробов: \(error)")
                }
            }
        }
    }

    func fetchWardrobe(by id: Int) {
        WardrobeService.shared.getWardrobe(by: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobe):
                    self.selectedWardrobe = wardrobe
                case .failure(let error):
                    print("❌ Ошибка получения гардероба: \(error)")
                }
            }
        }
    }

    func removeWardrobe(id: Int, completion: @escaping () -> Void) {
        WardrobeService.shared.removeWardrobe(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.wardrobes.removeAll { $0.id == id }
                    completion()
                case .failure(let error):
                    print("❌ Ошибка удаления гардероба: \(error)")
                }
            }
        }
    }

    func createWardrobe(name: String, isPrivate: Bool, completion: @escaping () -> Void) {
        let request = CreateWardrobeRequest(
            name: name,
            description: "default", // пока просто заглушка
            isPrivate: isPrivate
        )

        WardrobeService.shared.createWardrobe(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.fetchWardrobes()
                    completion()
                case .failure(let error):
                    print("❌ Ошибка создания гардероба: \(error.localizedDescription)")
                }
            }
        }
    }
    
}
