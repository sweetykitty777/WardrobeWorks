import SwiftUI

struct CreateWardrobeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var isPublic: Bool = true

    var viewModel: WardrobeViewModel
    var onSave: ((String, Bool, @escaping () -> Void) -> Void)?

    var body: some View {
        Form {
            Section(header: Text("Название")) {
                TextField("Введите название гардероба", text: Binding(
                    get: { self.name },
                    set: { newValue in
                        if newValue.count <= InputLimits.wardrobeNameMaxLength {
                            self.name = newValue
                        } else {
                            self.name = String(newValue.prefix(InputLimits.wardrobeNameMaxLength))
                        }
                    }
                ))
            }

            Section(header: Text("Доступ")) {
                Picker("Тип доступа", selection: $isPublic) {
                    Text("Публичный").tag(false)
                    Text("Приватный").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Новый гардероб")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    onSave?(name, isPublic) {
                        dismiss()
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
