import SwiftUI

struct WardrobeTabView: View {
    @State private var selectedTab: WardrobeTab = .clothes // ✅ Выбранная вкладка
    @State private var selectedItems: [OutfitItem] = [] // ✅ Список выбранных вещей
    @StateObject private var outfitViewModel = OutfitViewModel() // ✅ Создаем ViewModel для аутфитов

    var body: some View {
        VStack(spacing: 0) {
            // ✅ Верхняя панель вкладок
            TabBar(selectedTab: $selectedTab)
                .background(Color(.systemBackground))
                .zIndex(1) // ✅ Поднимаем над контентом

            // ✅ Контент вкладок с передачей ViewModel
            TabContent(selectedTab: selectedTab, selectedItems: $selectedItems, viewModel: outfitViewModel) // ✅ Передаем ViewModel
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        }
    }
}

// ✅ Вкладки
enum WardrobeTab: String, CaseIterable {
    case clothes = "Вещи"
    case outfits = "Аутфиты"
    case collections = "Лукбуки"
}

struct TabContent: View {
    var selectedTab: WardrobeTab
    @Binding var selectedItems: [OutfitItem] // ✅ Теперь принимаем `selectedItems`
    @ObservedObject var viewModel: OutfitViewModel // ✅ Добавляем ViewModel

    var body: some View {
        switch selectedTab {
        case .clothes:
            ClothesView(selectedItems: $selectedItems) // ✅ Передаем `selectedItems`
        case .outfits:
            OutfitsView(viewModel: viewModel) // ✅ Теперь передаем `viewModel` в OutfitsView
        case .collections:
            CollectionsView()
        }
    }
}
