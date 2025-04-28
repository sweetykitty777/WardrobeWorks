import SwiftUI

struct ClothesView: View {
    @Binding var selectedItems: [OutfitItem]
    var wardrobeId: Int

    @StateObject private var viewModel = ClothesViewModel()
    @State private var showingAddClothing = false

    private var groupedClothes: [String: [ClothItem]] {
        Dictionary(grouping: viewModel.clothes, by: { $0.category })
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(groupedClothes.keys.sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 24)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 12) {
                                        ForEach(groupedClothes[category] ?? []) { item in
                                            ClothItemView(item: item, selectedItems: $selectedItems)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                }

                Divider()

                Button(action: {
                    showingAddClothing = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить вещь")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchClothes(for: wardrobeId)
            }
        }
        .sheet(isPresented: $showingAddClothing, onDismiss: {
            viewModel.fetchClothes(for: wardrobeId)
        }) {
            AddClothingItemView(viewModel: AddClothingItemViewModel())
        }

    }
}
