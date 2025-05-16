import SwiftUI

struct CreateOutfitView: View {
    @ObservedObject var viewModel: OutfitViewModel
    @State private var showingWardrobe = false
    @State private var outfitItems: [OutfitItem] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // ✅ Холст для аутфита
                GeometryReader { geometry in
                    ZStack {
                        Color.white
                            .cornerRadius(20)
                            .shadow(radius: 2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        if outfitItems.isEmpty {
                            Text("Добавьте вещи")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(outfitItems.indices, id: \.self) { index in
                                DraggableItem(item: $outfitItems[index], canvasSize: geometry.size)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer().frame(height: 10)

                // ✅ Кнопка "Добавить вещи"
                Button(action: {
                    showingWardrobe = true
                }) {
                    HStack {
                        Text("Добавить вещи")
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
                .padding(.horizontal, 20)

                // ✅ Кнопка "Сохранить"
                Button(action: {
                    saveOutfit()
                }) {
                    HStack {
                        Text("Сохранить")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Создать аутфит")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingWardrobe, onDismiss: {
                print("Wardrobe закрыт, вещей в аутфите: \(outfitItems.count)")
            }) {
                WardrobeSelectionView(selectedItems: $outfitItems)
            }
        }
    }

    private func saveOutfit() {
        viewModel.addOutfit(name: "Новый аутфит", outfitItems: outfitItems)
        print("Аутфит сохранен с \(outfitItems.count) вещами")
    }
}
