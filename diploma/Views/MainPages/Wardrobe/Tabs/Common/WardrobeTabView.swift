import SwiftUI

struct WardrobeTabView: View {
    @State private var selectedTab: WardrobeTab = .clothes
    @State private var selectedItems: [OutfitItem] = []
    @StateObject private var outfitViewModel = OutfitViewModel()
    @StateObject private var wardrobeViewModel = WardrobeViewModel()

    @State private var selectedWardrobe: String = "Выбрать"
    @State private var selectedWardrobeId: Int? = nil
    @State private var showingCreateWardrobe = false
    @State private var editingWardrobe: UsersWardrobe? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // выпадающий список гардеробов
                Menu {
                    ForEach(wardrobeViewModel.wardrobes, id: \.id) { wardrobe in
                        Button(action: {
                            selectedWardrobe = wardrobe.name
                            selectedWardrobeId = wardrobe.id
                        }) {
                            Text(wardrobe.name)
                        }
                    }

                    Divider()

                    Button(action: {
                        showingCreateWardrobe = true
                    }) {
                        Label("Создать гардероб", systemImage: "plus")
                    }
                } label: {
                    HStack {
                        Text(selectedWardrobe)
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(height: 44)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                let currentWardrobe = wardrobeViewModel.wardrobes.first(where: { $0.name == selectedWardrobe })

                Button(action: {
                    if let wardrobe = currentWardrobe {
                        editingWardrobe = wardrobe
                    }
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(currentWardrobe == nil ? .gray : .blue)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .disabled(currentWardrobe == nil)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            WardrobeTabBarView(selectedTab: $selectedTab)
                .padding(.vertical, 12)

            TabContent(
                selectedTab: selectedTab,
                selectedItems: $selectedItems,
                viewModel: outfitViewModel,
                wardrobeId: selectedWardrobeId // Pass the selected wardrobe ID here
            )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            wardrobeViewModel.fetchWardrobes()
        }
        .sheet(isPresented: $showingCreateWardrobe) {
            CreateWardrobeView(viewModel: wardrobeViewModel) { name, isPrivate, completion in
                wardrobeViewModel.createWardrobe(name: name, isPrivate: isPrivate) {
                    wardrobeViewModel.fetchWardrobes()
                    completion()
                }
            }
        }
        .sheet(item: $editingWardrobe) { wardrobe in
            EditWardrobeView(
                wardrobe: wardrobe,
                onSave: { updated in
                    if let index = wardrobeViewModel.wardrobes.firstIndex(where: { $0.id == updated.id }) {
                        wardrobeViewModel.wardrobes[index] = updated
                    }
                },
                onDelete: { deleted in
                    wardrobeViewModel.wardrobes.removeAll { $0.id == deleted.id }
                    if selectedWardrobe == deleted.name {
                        selectedWardrobe = "Выбрать"
                        selectedWardrobeId = nil
                    }
                }
            )
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
    var wardrobeId: Int?

    var body: some View {
        Group {
            switch selectedTab {
            case .clothes:
                if let id = wardrobeId {
                    ClothesView(selectedItems: $selectedItems, wardrobeId: id)
                } else {
                    placeholder
                }
            case .outfits:
                if let id = wardrobeId {
                    OutfitsView(viewModel: viewModel, wardrobeId: id)
                } else {
                    placeholder
                }
            case .collections:
                if let id = wardrobeId {
                    CollectionsView(wardrobeId: id)
                } else {
                    placeholder
                }
            }
        }
        .background(Color.white)
    }

    private var placeholder: some View {
        Text("Выберите гардероб")
            .foregroundColor(.gray)
            .font(.subheadline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
}
