import SwiftUI
/*
struct OutfitCanvasView: View {
    @State private var outfitItems: [OutfitItem] = []
    @State private var showingWardrobe = false

    @StateObject private var wardrobeViewModel = WardrobeViewModel()
    @State private var selectedWardrobeName: String = "Выбрать гардероб"
    @State private var selectedWardrobeId: Int?

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Верхняя панель
                    HStack {
                        Button(action: {
                            // Назад
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .padding()
                        }

                        Spacer()

                        Button(action: {
                            saveOutfit()
                        }) {
                            HStack {
                                Text("Сохранить")
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Выпадающий список гардеробов
                    Menu {
                        ForEach(wardrobeViewModel.wardrobes, id: \.id) { wardrobe in
                            Button(wardrobe.name) {
                                selectedWardrobeName = wardrobe.name
                                selectedWardrobeId = wardrobe.id
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedWardrobeName)
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
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    // Полотно с вещами
                    ZStack {
                        Color.white
                            .cornerRadius(20)
                            .shadow(radius: 2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        ForEach(outfitItems.indices, id: \.self) { index in
                            DraggableItem(item: $outfitItems[index], canvasSize: geometry.size)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // Кнопка добавления вещей
                    Button(action: {
                        showingWardrobe = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Добавить вещи")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .padding()
                }
                .onAppear {
                    wardrobeViewModel.fetchWardrobes()
                }
                .sheet(isPresented: $showingWardrobe) {
                    WardrobeSelectionView(selectedItems: $outfitItems)
                }
            }
        }
    }

    private func saveOutfit() {
        guard let wardrobeId = selectedWardrobeId else {
            print("❌ Гардероб не выбран")
            return
        }

        print("✅ Сохраняем аутфит в гардеробе ID \(wardrobeId):")
        for item in outfitItems {
            print("• \(item.name)")
        }

        // TODO: отправка на сервер, если будет API
    }
}

*/
