import SwiftUI

struct WardrobeSelectionView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedItems: [PlacedClothingItem]
    let wardrobeId: Int
    @Binding var imageURLs: [Int: String]

    let canvasSize: CGSize
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 15)]

    @StateObject private var viewModel = WardrobeSelectionViewModel()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { viewModel.showFilters.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.filteredItems, id: \.id) { item in
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                CachedImageView(
                                    urlString: item.imagePath,
                                    width: 100,
                                    height: 100
                                )
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.selectedIds.contains(item.id) ? Color.blue : Color.clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                viewModel.toggleSelection(for: item)
                            }

                            if viewModel.selectedIds.contains(item.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .padding(6)
                            }
                        }
                    }
                }
                .padding()
            }

            VStack(spacing: 10) {
                Button("Сбросить выбор") {
                    viewModel.selectedIds.removeAll()
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)

                Button("Добавить выбранные") {
                    addSelectedItems()
                    dismiss()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(viewModel.selectedIds.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .cornerRadius(10)
                .shadow(radius: 1)
                .disabled(viewModel.selectedIds.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Выберите вещь")
        .onAppear {
            viewModel.fetchClothes(for: wardrobeId)
        }
        .overlay(
            viewModel.showFilters ? FiltersBottomSheet(
                isPresented: $viewModel.showFilters,
                selectedCategories: $viewModel.selectedCategories,
                selectedBrands: $viewModel.selectedBrands,
                selectedColors: $viewModel.selectedColors,
                selectedSeasons: $viewModel.selectedSeasons,
                selectedPriceRanges: $viewModel.selectedPriceRanges
            )
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: viewModel.showFilters) : nil
        )
    }

    private func addSelectedItems() {
        for item in viewModel.wardrobeItems where viewModel.selectedIds.contains(item.id) {
            let newItem = PlacedClothingItem(
                clothId: item.id,
                x: 0,
                y: 0,
                rotation: 0,
                scale: 1.0,
                zIndex: 0
            )
            selectedItems.append(newItem)
            imageURLs[item.id] = item.imagePath
        }
        viewModel.selectedIds.removeAll()
    }
}
