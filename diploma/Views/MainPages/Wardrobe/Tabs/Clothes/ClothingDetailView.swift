import SwiftUI

struct ClothingDetailView: View {
    let item: ClothItem
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var price: String = ""
    @State private var description: String = ""

    @State private var selectedType: ClothingContentItem?
    @State private var selectedBrand: ClothingContentItem?
    @State private var selectedSeason: ClothingContentItem?
    @State private var selectedColor: ClothingColor?

    @State private var clothingTypes: [ClothingContentItem] = []
    @State private var brands: [ClothingContentItem] = []
    @State private var seasons: [ClothingContentItem] = []
    @State private var colors: [ClothingColor] = []

    @State private var editableItem: ClothItem

    init(item: ClothItem) {
        self.item = item
        _editableItem = State(initialValue: item)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: — Большое изображение без искажений
                if let url = URL(string: editableItem.imagePath) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()                   // сохраняем пропорции
                                .frame(maxWidth: .infinity)      // разворачиваем на всю ширину
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(radius: 4)
                                .padding(.horizontal)
                        case .failure:
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.1))
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 220)
                            .padding(.horizontal)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // MARK: — Информация о вещи
                VStack(alignment: .leading, spacing: 16) {
                    if isEditing {
                        CustomSelectableNavigationLink(
                            title: "Категория",
                            selectedItem: $selectedType,
                            destination: ContentSelectionView(items: clothingTypes, selectedItem: $selectedType)
                        )
                        CustomSelectableNavigationLink(
                            title: "Бренд",
                            selectedItem: $selectedBrand,
                            destination: ContentSelectionView(items: brands, selectedItem: $selectedBrand)
                        )
                        CustomSelectableNavigationLink(
                            title: "Цвет",
                            selectedItem: $selectedColor,
                            destination: ContentSelectionView(items: colors, selectedItem: $selectedColor),
                            showColorDot: true
                        )
                        CustomSelectableNavigationLink(
                            title: "Сезон",
                            selectedItem: $selectedSeason,
                            destination: ContentSelectionView(items: seasons, selectedItem: $selectedSeason)
                        )
                        CustomTextField(title: "Цена", text: $price, keyboardType: .decimalPad)
                        CustomTextField(title: "Описание", text: $description)
                    } else {
                        InfoRow(title: "Бренд", value: editableItem.brandName ?? "—")
                        InfoRow(title: "Цвет", value: editableItem.colourName ?? "—")
                        InfoRow(title: "Сезон", value: editableItem.seasonName ?? "—")
                        InfoRow(title: "Категория", value: editableItem.typeName ?? "—")
                        InfoRow(title: "Цена", value: "\(editableItem.price ?? 0) ₽")
                        InfoRow(title: "Описание", value: editableItem.description ?? "—")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)

                // MARK: — Кнопка сохранить (в режиме редактирования)
                if isEditing {
                    Button(action: saveChanges) {
                        Text(isSaving ? "Сохранение..." : "Сохранить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal)
                }

                // MARK: — Кнопка удалить вещь
                Button(role: .destructive) {
                    confirmDelete()
                } label: {
                    Text("Удалить вещь")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            price = "\(editableItem.price ?? 0)"
            description = editableItem.description ?? ""
        }
        .navigationTitle("Вещь")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Отмена" : "Редактировать") {
                    if !isEditing {
                        fetchContent()
                    }
                    isEditing.toggle()
                }
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("Ок", role: .cancel) {}
        }
    }

    private func fetchContent() {
        ContentService.shared.fetchAll { types, brandsList, colorsList, seasonsList in
            DispatchQueue.main.async {
                clothingTypes = types
                brands = brandsList
                colors = colorsList
                seasons = seasonsList

                selectedType = types.first(where: { $0.name == item.typeName })
                selectedBrand = brandsList.first(where: { $0.name == item.brandName })
                selectedSeason = seasonsList.first(where: { $0.name == item.seasonName })
                selectedColor = colorsList.first(where: { $0.name == item.colourName })
            }
        }
    }

    private func saveChanges() {
        let request = UpdateClothingItemRequest(
            price: Int(price),
            typeId: selectedType?.id,
            colourId: selectedColor?.id,
            seasonId: selectedSeason?.id,
            brandId: selectedBrand?.id,
            description: description.isEmpty ? nil : description
        )

        guard request.price != nil ||
              request.typeId != nil ||
              request.colourId != nil ||
              request.seasonId != nil ||
              request.brandId != nil ||
              request.description != nil else {
            alertMessage = "Заполните хотя бы одно поле"
            showAlert = true
            return
        }

        isSaving = true
        WardrobeService.shared.updateClothingItem(id: editableItem.id, request: request) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    alertMessage = "✅ Изменения сохранены"
                    editableItem = ClothItem(
                        id: editableItem.id,
                        description: request.description ?? editableItem.description,
                        imagePath: editableItem.imagePath,
                        price: request.price ?? editableItem.price,
                        typeName: selectedType?.name ?? editableItem.typeName,
                        colourName: selectedColor?.name ?? editableItem.colourName,
                        seasonName: selectedSeason?.name ?? editableItem.seasonName,
                        brandName: selectedBrand?.name ?? editableItem.brandName
                    )
                    isEditing = false
                case .failure:
                    alertMessage = "❌ Ошибка при сохранении"
                }
                showAlert = true
            }
        }
    }

    private func confirmDelete() {
        WardrobeService.shared.deleteClothingItem(id: editableItem.id) { success in
            DispatchQueue.main.async {
                if success {
                    dismiss()
                } else {
                    alertMessage = "❌ Не удалось удалить"
                    showAlert = true
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).fontWeight(.semibold)
            Spacer()
            Text(value).foregroundColor(.gray)
        }
        .font(.system(size: 16))
    }
}
