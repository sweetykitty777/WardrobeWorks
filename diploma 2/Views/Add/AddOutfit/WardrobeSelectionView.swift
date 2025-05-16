import SwiftUI

struct WardrobeSelectionView: View {
    @Binding var selectedItems: [OutfitItem]
    @State private var wardrobeItems: [ClothingItem] = MockData.clothingItems
    @State private var showFilters = false

    // ✅ Фильтры
    @State private var selectedCategories: Set<String> = []
    @State private var selectedBrands: Set<String> = []
    @State private var selectedColors: Set<String> = []
    @State private var selectedSeasons: Set<String> = []
    @State private var selectedPriceRanges: Set<String> = []

    let columns = [GridItem(.adaptive(minimum: 100), spacing: 15)]

    var filteredItems: [ClothingItem] {
        wardrobeItems.filter { item in
            (selectedCategories.isEmpty || selectedCategories.contains(item.category ?? "")) &&
            (selectedBrands.isEmpty || selectedBrands.contains(item.brand ?? "")) &&
            (selectedColors.isEmpty || selectedColors.contains(item.color ?? "")) &&
            (selectedSeasons.isEmpty || selectedSeasons.contains(item.season ?? "")) &&
            (selectedPriceRanges.isEmpty || selectedPriceRanges.contains(item.price ?? ""))
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // ✅ Кнопка "Фильтр"
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

                // ✅ Отображение вещей в сетке
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredItems, id: \.id) { item in
                            VStack {
                                if let imageName = item.image_str, let image = UIImage(named: imageName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Image(systemName: "photo") // Заглушка
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                }


                                Text(item.name)
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                            .padding(5)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                            .onTapGesture {
                                addItemAndClose(item)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Выберите вещь")

            // ✅ Всплывающее окно с фильтрами
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
                .animation(.easeInOut) : nil
            )
        }
    }

    /// ✅ Добавляем вещь и закрываем экран
    private func addItemAndClose(_ item: ClothingItem) {
        selectedItems.append(OutfitItem(
            name: item.name,
            imageName: item.image_str ?? "placeholder",
            position: CGPoint(x: 150, y: 150)
        ))
    }
}
