import SwiftUI

struct OutfitCanvasView: View {
    @State private var outfitItems: [OutfitItem] = []
    @State private var showingWardrobe = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Button(action: {
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
                                Text("Save")
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

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
                .sheet(isPresented: $showingWardrobe) {
                    WardrobeSelectionView(selectedItems: $outfitItems)
                }
            }
        }
    }

    private func saveOutfit() {
        print("Аутфит сохранён: \(outfitItems.map { $0.name })")
    }
}
