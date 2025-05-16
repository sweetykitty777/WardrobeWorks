import SwiftUI

struct FiltersBottomSheet: View {
    @Binding var isPresented: Bool

    @Binding var selectedCategories: Set<String>
    @Binding var selectedBrands: Set<String>
    @Binding var selectedColors: Set<String>
    @Binding var selectedSeasons: Set<String>
    @Binding var selectedPriceRanges: Set<String>

    let categories = ["Брюки", "Верх", "Обувь", "Аксессуары", "Платья", "Рубашки"]
    let brands = ["Nike", "Adidas", "Gucci", "Zara"]
    let colors = ["Красный", "Синий", "Чёрный", "Белый", "Зелёный", "Жёлтый"]
    let seasons = ["Лето", "Зима", "Осень", "Весна"]
    let priceRanges = ["До 1000 ₽", "1000-5000 ₽", "5000-10000 ₽", "10000+ ₽"]

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 50, height: 5)
                .padding(.top, 8)

            Text("Фильтры")
                .font(.headline)
                .padding(.top, 10)

            ScrollView {
                VStack(spacing: 15) {
                    FilterSection(title: "Категория", options: categories, selectedOptions: $selectedCategories)
                    FilterSection(title: "Цвет", options: colors, selectedOptions: $selectedColors)
                    FilterSection(title: "Сезон", options: seasons, selectedOptions: $selectedSeasons)
                    FilterSection(title: "Бренд", options: brands, selectedOptions: $selectedBrands)
                    FilterSection(title: "Цена", options: priceRanges, selectedOptions: $selectedPriceRanges)
                }
                .padding(.horizontal)
            }

            HStack {
                Button("Сбросить", action: resetFilters)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)

                Button("Применить", action: { isPresented = false })
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        .transition(.move(edge: .bottom))
        .animation(.spring(), value: isPresented)
    }

    private func resetFilters() {
        selectedCategories.removeAll()
        selectedBrands.removeAll()
        selectedColors.removeAll()
        selectedSeasons.removeAll()
        selectedPriceRanges.removeAll()
    }
}

