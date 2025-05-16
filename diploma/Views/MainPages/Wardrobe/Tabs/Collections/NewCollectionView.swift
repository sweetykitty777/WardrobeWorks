import SwiftUI

struct NewCollectionView: View {
    var onCreate: () -> Void
    @Binding var isPresented: Bool

    @State private var collectionName: String = ""
    @State private var descriptionText: String = ""
    @State private var selectedWardrobeId: Int?
    @StateObject private var wardrobeViewModel = WardrobeViewModel()
    @State private var isCreating = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isErrorToast = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Название лукбука")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                TextField("Введите название", text: $collectionName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .onChange(of: collectionName) { newValue in
                        if newValue.count > 30 {
                            collectionName = String(newValue.prefix(30))
                        }
                    }

                Text("\(collectionName.count)/30 символов")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            // Описание
            VStack(alignment: .leading, spacing: 4) {
                Text("Описание")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                TextField("Введите описание", text: $descriptionText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .onChange(of: descriptionText) { newValue in
                        if newValue.count > 30 {
                            descriptionText = String(newValue.prefix(30))
                        }
                    }

                Text("\(descriptionText.count)/30 символов")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            // Меню выбора гардероба
            VStack(alignment: .leading, spacing: 4) {
                Text("Выбрать гардероб")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                Menu {
                    ForEach(wardrobeViewModel.wardrobes, id: \.id) { wardrobe in
                        Button(wardrobe.name) {
                            selectedWardrobeId = wardrobe.id
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedWardrobeName)
                            .foregroundColor(selectedWardrobeId == nil ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
            }

            Spacer()

            // Кнопка создания
            Button(action: {
                createLookbook()
            }) {
                Text(isCreating ? "Создание..." : "Создать")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        (isCreating || collectionName.isEmpty || selectedWardrobeId == nil)
                        ? Color.gray.opacity(0.5)
                        : Color.blue
                    )
                    .cornerRadius(14)
                    .padding(.horizontal)
            }
            .disabled(isCreating || collectionName.isEmpty || selectedWardrobeId == nil)

            // Toast
            if showToast {
                VStack {
                    Spacer()
                    ToastView(message: toastMessage, isError: isErrorToast)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: showToast)
                }
                .zIndex(1)
            }
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Новый лукбук")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Отмена") {
                    dismiss()
                }
            }
        }
        .onAppear {
            wardrobeViewModel.fetchWardrobes()
        }
    }

    private var selectedWardrobeName: String {
        if let id = selectedWardrobeId,
           let wardrobe = wardrobeViewModel.wardrobes.first(where: { $0.id == id }) {
            return wardrobe.name
        } else {
            return "Выбрать гардероб"
        }
    }

    private func createLookbook() {
        guard let wardrobeId = selectedWardrobeId else { return }

        isCreating = true

        WardrobeService.shared.createLookbook(
            wardrobeId: wardrobeId,
            name: collectionName,
            description: descriptionText
        ) { result in
            DispatchQueue.main.async {
                isCreating = false
                switch result {
                case .success:
                    onCreate()
                    toastMessage = "Лукбук успешно создан"
                    isErrorToast = false
                    showToast = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isPresented = false
                        showToast = false
                    }

                case .failure(let error):
                    print("Ошибка создания лукбука: \(error.localizedDescription)")
                    toastMessage = "Не удалось создать лукбук"
                    isErrorToast = true
                    showToast = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showToast = false
                    }
                }
            }
        }
    }
}
