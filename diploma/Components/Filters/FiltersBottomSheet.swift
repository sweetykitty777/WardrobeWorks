import SwiftUI

struct FiltersBottomSheet: View {
    @Binding var isPresented: Bool

    @Binding var selectedCategories: Set<String>
    @Binding var selectedBrands: Set<String>
    @Binding var selectedColors: Set<String>
    @Binding var selectedSeasons: Set<String>
    @Binding var selectedPriceRanges: Set<String>

    @StateObject private var viewModel = FilterOptionsViewModel()

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
                    FilterSection(title: "Категория", options: viewModel.categories, selectedOptions: $selectedCategories)
                    FilterSection(title: "Цвет", options: viewModel.colors, selectedOptions: $selectedColors)
                    FilterSection(title: "Сезон", options: viewModel.seasons, selectedOptions: $selectedSeasons)
                    FilterSection(title: "Бренд", options: viewModel.brands, selectedOptions: $selectedBrands)
                    FilterSection(title: "Цена", options: viewModel.priceRanges, selectedOptions: $selectedPriceRanges)
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
        .onAppear {
            viewModel.fetchAll()
        }
    }

    private func resetFilters() {
        selectedCategories.removeAll()
        selectedBrands.removeAll()
        selectedColors.removeAll()
        selectedSeasons.removeAll()
        selectedPriceRanges.removeAll()
    }
}
