import SwiftUI

struct EditWardrobeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var wardrobe: UsersWardrobe
    var onSave: (UsersWardrobe) -> Void
    var onDelete: (UsersWardrobe) -> Void

    @State private var isDeleting = false
    @State private var showDeleteError = false

    @State private var showAccessSheet = false
    @State private var accesses: [SharedAccess] = []

    var body: some View {
        NavigationView {
            Form {
                // Название
                Section(header: Text("Название")) {
                    TextField("Название", text: $wardrobe.name)
                }

                // Приватность
                Section(header: Text("Приватность")) {
                    Toggle("Приватный", isOn: $wardrobe.isPrivate)
                }

                // Кнопка "Поделиться"
                Section {
                    Button(action: {
                        loadAccesses()
                        showAccessSheet = true
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Поделиться доступом")
                        }
                    }
                }

                // Удаление
                Section {
                    if isDeleting {
                        ProgressView().frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button(role: .destructive) {
                            isDeleting = true
                            WardrobeService.shared.removeWardrobe(id: wardrobe.id) { result in
                                DispatchQueue.main.async {
                                    isDeleting = false
                                    switch result {
                                    case .success:
                                        onDelete(wardrobe)
                                        presentationMode.wrappedValue.dismiss()
                                    case .failure:
                                        showDeleteError = true
                                    }
                                }
                            }
                        } label: {
                            Text("Удалить гардероб")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarItems(trailing: Button("Сохранить") {
                onSave(wardrobe)
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showDeleteError) {
                Alert(title: Text("Ошибка"), message: Text("Не удалось удалить гардероб."), dismissButton: .default(Text("Ок")))
            }
            .sheet(isPresented: $showAccessSheet) {
                ShareAccessView(viewModel: ShareAccessViewModel(wardrobeId: wardrobe.id))
            }
        }
    }

    private func loadAccesses() {
        WardrobeService.shared.fetchAccessList { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    accesses = list.filter { $0.wardrobeId == wardrobe.id }
                case .failure(let error):
                    print("Ошибка загрузки доступов: \(error)")
                }
            }
        }
    }
}
