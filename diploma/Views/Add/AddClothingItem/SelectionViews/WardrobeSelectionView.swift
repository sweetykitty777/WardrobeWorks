import SwiftUI

struct WardrobeSelectionView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedItems: [PlacedClothingItem]
    let wardrobeId: Int
    @Binding var imageURLs: [Int: String]

    @State private var wardrobeItems: [ClothItem] = []
    @State private var selectedIds: Set<Int> = []
    @State private var showFilters = false

    @State private var selectedCategories: Set<String> = []
    @State private var selectedBrands: Set<String> = []
    @State private var selectedColors: Set<String> = []
    @State private var selectedSeasons: Set<String> = []
    @State private var selectedPriceRanges: Set<String> = []

    let columns = [GridItem(.adaptive(minimum: 100), spacing: 15)]

    var filteredItems: [ClothItem] {
        wardrobeItems.filter { item in
            (selectedCategories.isEmpty || selectedCategories.contains(item.category)) &&
            (selectedBrands.isEmpty || selectedBrands.contains(item.brandName ?? "")) &&
            (selectedColors.isEmpty || selectedColors.contains(item.colourName ?? "")) &&
            (selectedSeasons.isEmpty || selectedSeasons.contains(item.seasonName ?? "")) &&
            (selectedPriceRanges.isEmpty || selectedPriceRanges.contains("\(item.price ?? 0)"))
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredItems, id: \.id) { item in
                            ZStack(alignment: .topTrailing) {
                                VStack {
                                    RemoteImageView(urlString: item.imagePath)
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedIds.contains(item.id) ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    toggleSelection(for: item)
                                }

                                if selectedIds.contains(item.id) {
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
                        selectedIds.removeAll()
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
                    .background(selectedIds.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .disabled(selectedIds.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Выберите вещь")
            .onAppear {
                fetchClothes()
            }
            .overlay(
                showFilters ? FiltersBottomSheet(
                    isPresented: $showFilters,
                    selectedCategories: $selectedCategories,
                    selectedBrands: $selectedBrands,
                    selectedColors: $selectedColors,
                    selectedSeasons: $selectedSeasons,
                    selectedPriceRanges: $selectedPriceRanges
                )
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showFilters) : nil
            )
        }
    }

    private func fetchClothes() {
        WardrobeService.shared.fetchClothes(for: wardrobeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    wardrobeItems = items
                case .failure(let error):
                    print("Ошибка загрузки одежды: \(error)")
                }
            }
        }
    }

    private func toggleSelection(for item: ClothItem) {
        if selectedIds.contains(item.id) {
            selectedIds.remove(item.id)
        } else {
            selectedIds.insert(item.id)
        }
    }

    private func addSelectedItems() {
        for item in wardrobeItems where selectedIds.contains(item.id) {
            let newItem = PlacedClothingItem(
                clothId: item.id,
                x: 150, y: 150,
                rotation: 0, scale: 1.0,
                zIndex: 0
            )
            selectedItems.append(newItem)
            imageURLs[item.id] = item.imagePath
        }
        selectedIds.removeAll()
    }
}
