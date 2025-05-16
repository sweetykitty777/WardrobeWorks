import SwiftUI


struct ClothesView: View {
    @Binding var selectedItems: [OutfitItem]
    var wardrobeId: Int

    @StateObject private var viewModel = ClothesViewModel()

    private var groupedClothes: [String: [ClothingItem]] {
        Dictionary(grouping: viewModel.clothes, by: { $0.category ?? "Без категории" })
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(groupedClothes.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading) {
                            Text(category)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color(.label))
                                .padding(.horizontal, 20)
                                .padding(.top, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 4) {
                                    ForEach(groupedClothes[category] ?? []) { item in
                                        ClothingItemView(item: item, selectedItems: $selectedItems)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchClothes(for: wardrobeId)
            }
        }
    }
}
