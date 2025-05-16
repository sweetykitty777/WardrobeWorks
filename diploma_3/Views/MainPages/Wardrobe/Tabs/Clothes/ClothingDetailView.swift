import SwiftUI

struct ClothingDetailView: View {
    @Binding var item: ClothingItem
    @Binding var clothingItems: [ClothingItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    
                    // Фото
                    if let imageName = item.image_str,
                       let image = UIImage(named: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray.opacity(0.4))
                            .padding(.horizontal)
                    }
                    
                    // 📋 Блок с информацией
                    VStack(alignment: .leading, spacing: 16) {
                        if isEditing {
                            CustomEditableRow(title: "Название", text: $item.name)
                            CustomEditableRow(title: "Бренд", text: Binding(get: { item.brand ?? "" }, set: { item.brand = $0 }))
                            CustomEditableRow(title: "Цвет", text: Binding(get: { item.color ?? "" }, set: { item.color = $0 }))
                            CustomEditableRow(title: "Сезон", text: Binding(get: { item.season ?? "" }, set: { item.season = $0 }))
                            CustomEditableRow(title: "Цена", text: Binding(get: { item.price ?? "" }, set: { item.price = $0 }))
                        } else {
                            InfoRow(title: "Название", value: item.name)
                            if let brand = item.brand {
                                InfoRow(title: "Бренд", value: brand)
                            }
                            if let color = item.color {
                                InfoRow(title: "Цвет", value: color)
                            }
                            if let season = item.season {
                                InfoRow(title: "Сезон", value: season)
                            }
                            if let price = item.price {
                                InfoRow(title: "Цена", value: price)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Удаление
                    if isEditing {
                        Button(role: .destructive) {
                            deleteItem()
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
                }
                .padding(.top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Готово" : "Редактировать")
                }
            }
        }
    }

    private func deleteItem() {
        if let index = clothingItems.firstIndex(where: { $0.id == item.id }) {
            clothingItems.remove(at: index)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .font(.system(size: 16))
    }
}

struct CustomEditableRow: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            TextField(title, text: $text)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}
