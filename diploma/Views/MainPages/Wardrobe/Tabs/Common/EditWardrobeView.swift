import SwiftUI

struct EditWardrobeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var wardrobe: UsersWardrobe
    var onSave: (UsersWardrobe) -> Void
    var onDelete: (UsersWardrobe) -> Void

    @State private var isDeleting = false
    @State private var showDeleteError = false
    @State private var showAccessSheet = false
    @State private var showPrivacyError = false
    @State private var prevIsPrivate: Bool

    init(wardrobe: UsersWardrobe,
         onSave: @escaping (UsersWardrobe) -> Void,
         onDelete: @escaping (UsersWardrobe) -> Void) {
        _wardrobe = State(initialValue: wardrobe)
        _prevIsPrivate = State(initialValue: wardrobe.isPrivate)
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название")) {
                    TextField("Название", text: $wardrobe.name)
                }

                Section(header: Text("Приватность")) {
                    Toggle("Приватный", isOn: $wardrobe.isPrivate)
                        .onChange(of: wardrobe.isPrivate) { newValue in
                            let old = prevIsPrivate
                            prevIsPrivate = newValue
                            WardrobeService.shared.changeWardrobePrivacy(id: wardrobe.id, isPrivate: newValue) { result in
                                switch result {
                                case .success:
                                    print("Приватность изменена на \(newValue)")
                                case .failure:
                                    wardrobe.isPrivate = old
                                    prevIsPrivate = old
                                    showPrivacyError = true
                                }
                            }
                        }
                }

                Section {
                    Button {
                        showAccessSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Поделиться доступом")
                        }
                    }
                }

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
            .navigationTitle("Редактировать гардероб")
            .navigationBarItems(trailing: Button("Сохранить") {
                onSave(wardrobe)
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Ошибка смены приватности", isPresented: $showPrivacyError) {
                Button("Ок", role: .cancel) {}
            }
            .alert("Ошибка удаления", isPresented: $showDeleteError) {
                Button("Ок", role: .cancel) {}
            }
            .sheet(isPresented: $showAccessSheet) {
                ShareAccessView(viewModel: ShareAccessViewModel(wardrobeId: wardrobe.id))
            }
        }
    }
}
