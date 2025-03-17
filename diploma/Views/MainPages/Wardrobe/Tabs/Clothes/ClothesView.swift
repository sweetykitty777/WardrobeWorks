import SwiftUI


struct ClothesView: View {
    @Binding var selectedItems: [OutfitItem]
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
                                    ClothingItemView(item: item, selectedItems: $selectedItems)
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

