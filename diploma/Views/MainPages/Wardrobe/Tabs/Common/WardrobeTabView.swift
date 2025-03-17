import SwiftUI

struct WardrobeTabView: View {
    @State private var selectedTab: WardrobeTab = .clothes
    @State private var selectedItems: [OutfitItem] = []
    @StateObject private var outfitViewModel = OutfitViewModel() 

    var body: some View {
        VStack(spacing: 0) {

            TabBar(selectedTab: $selectedTab)
                .background(Color(.systemBackground))
                .zIndex(1)

            TabContent(selectedTab: selectedTab, selectedItems: $selectedItems, viewModel: outfitViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        }
    }
}


enum WardrobeTab: String, CaseIterable {
    case clothes = "Вещи"
    case outfits = "Аутфиты"
    case collections = "Лукбуки"
}

struct TabContent: View {
    var selectedTab: WardrobeTab
    @Binding var selectedItems: [OutfitItem]
    @ObservedObject var viewModel: OutfitViewModel

    var body: some View {
        switch selectedTab {
        case .clothes:
            ClothesView(selectedItems: $selectedItems)
        case .outfits:
            OutfitsView(viewModel: viewModel)
        case .collections:
            CollectionsView()
        }
    }
}
