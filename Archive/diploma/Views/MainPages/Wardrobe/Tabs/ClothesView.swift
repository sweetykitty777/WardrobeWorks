import SwiftUI

struct ClothesView: View {
    @Binding var selectedItems: [OutfitItem] // 🔥 Добавляем привязку
    private let clothingItems = MockData.clothingItems

    private var groupedClothes: [String: [ClothingItem]] {
        Dictionary(grouping: clothingItems, by: { $0.category ?? "Без категории" })
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(groupedClothes.keys.sorted(), id: \.self) { category in
                    VStack(alignment: .leading) {
                        Text(category)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 15) {
                                ForEach(groupedClothes[category] ?? []) { item in
                                    ClothingItemView(item: item, selectedItems: $selectedItems) // ✅ Передаем binding
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top)
        }
    }
}

// Вспомогательное представление для одной вещи
struct ClothingItemView: View {
    let item: ClothingItem
    @Binding var selectedItems: [OutfitItem] // 🔥 Привязка к массиву выбранных вещей

    var body: some View {
        VStack {
            if let imageName = item.image_str, let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }

            Text(item.name)
                .font(.caption)
                .foregroundColor(.black)
        }
        .frame(width: 120)
        .onTapGesture {
            addItem(item) // ✅ Добавляем в список выбранных вещей
        }
    }

    private func addItem(_ item: ClothingItem) {
        let newItem = OutfitItem(
            name: item.name,
            imageName: item.image_str ?? "placeholder",
            position: CGPoint(x: 150, y: 150)
        )
        selectedItems.append(newItem)
    }
}


