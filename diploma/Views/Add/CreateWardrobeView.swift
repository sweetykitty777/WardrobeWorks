import SwiftUI


struct CreateWardrobeView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var isPublic: Bool = true

    var viewModel: WardrobeViewModel
    var onSave: ((String, Bool, @escaping () -> Void) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название")) {
                    TextField("Введите название гардероба", text: $name)
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
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    onSave?(name, isPublic) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}
