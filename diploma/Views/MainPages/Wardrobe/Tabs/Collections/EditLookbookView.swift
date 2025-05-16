import Foundation
import SwiftUI

struct EditLookbookView: View {
    var lookbookId: Int
    var initialName: String
    var initialDescription: String
    var onSave: () -> Void
    var onDelete: () -> Void

    @Environment(\.presentationMode) var presentationMode

    @State private var name: String
    @State private var descriptionText: String
    @State private var isSaving = false
    @State private var isDeleting = false

    init(lookbookId: Int, initialName: String, initialDescription: String, onSave: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.lookbookId = lookbookId
        self.initialName = initialName
        self.initialDescription = initialDescription
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: initialName)
        _descriptionText = State(initialValue: initialDescription)
    }

    var body: some View {
        VStack(spacing: 20) {
                TextField("Название", text: $name)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2))
                    )
                    .padding(.horizontal)
                    .onChange(of: name) { newValue in
                        if newValue.count > 30 {
                            name = String(newValue.prefix(30))
                        }
                    }

                TextField("Описание", text: $descriptionText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2))
                    )
                    .padding(.horizontal)
                    .onChange(of: descriptionText) { newValue in
                        if newValue.count > 30 {
                            descriptionText = String(newValue.prefix(30))
                        }
                    }

                Spacer()

                Button(action: updateLookbook) {
                    Text(isSaving ? "Сохранение..." : "Сохранить изменения")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                        .padding(.horizontal)
                }
                .disabled(isSaving)

                Button(role: .destructive, action: deleteLookbook) {
                    Text(isDeleting ? "Удаление..." : "Удалить лукбук")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(14)
                        .padding(.horizontal)
                }
                .disabled(isDeleting)
            .navigationTitle("Редактировать")
            .navigationBarItems(leading: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color(.systemGroupedBackground))
        }
    }

    private func updateLookbook() {
        isSaving = true
        WardrobeService.shared.updateLookbook(lookbookId: lookbookId, name: name, description: descriptionText) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Ошибка обновления лукбука:", error.localizedDescription)
                }
            }
        }
    }

    private func deleteLookbook() {
        isDeleting = true
        WardrobeService.shared.deleteLookbook(lookbookId: lookbookId) { result in
            DispatchQueue.main.async {
                isDeleting = false
                switch result {
                case .success:
                    onDelete()
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Ошибка удаления лукбука:", error.localizedDescription)
                }
            }
        }
    }
}
