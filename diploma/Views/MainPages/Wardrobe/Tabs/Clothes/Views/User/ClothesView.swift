import SwiftUI

struct ClothesView: View {
    @Binding var selectedItems: [OutfitItem]
    var wardrobeId: Int

    @StateObject private var viewModel = ClothesViewModel()
    @State private var showingAddClothing = false
    @State private var selectedItem: ClothItem?

    private var groupedClothes: [String: [ClothItem]] {
        Dictionary(grouping: viewModel.clothes, by: { $0.category })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView("Загрузка одежды...")
                            .padding()
                    } else if viewModel.clothes.isEmpty {
                        Text("У вас пока нет вещей")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
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
                                                NavigationLink(value: item) {
                                                    ClothItemView(item: item, selectedItems: $selectedItems)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 10)
                                    }
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
            .navigationDestination(for: ClothItem.self) { item in
                ClothingDetailView(item: item)
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchClothes(for: wardrobeId)
            }
            .onChange(of: wardrobeId) { newId in
                viewModel.fetchClothes(for: newId)
            }
        }
        .fullScreenCover(isPresented: $showingAddClothing, onDismiss: {
            viewModel.fetchClothes(for: wardrobeId)
        }) {
            NavigationStack {
                AddClothingItemView(
                    viewModel: AddClothingItemViewModel(),
                    clothesViewModel: viewModel
                )
            }
        }
    }
}
