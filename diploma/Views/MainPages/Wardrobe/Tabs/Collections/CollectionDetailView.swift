import SwiftUI

struct CollectionDetailView: View {
    @Binding var collection: Collection
    @State private var showingOutfitPicker = false
    @State private var selectedOutfits: [Outfit] = []

    var body: some View {
        VStack {
            HStack {
                Button("Добавить аутфиты") {
                    showingOutfitPicker = true
                }
                .padding()
            }

            if collection.outfits.isEmpty {
                Text("В этой коллекции пока нет аутфитов.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(collection.outfits.indices, id: \.self) { index in
                        HStack {
                            OutfitCard(outfit: collection.outfits[index])
                                .contextMenu {
                                    Button("Удалить", role: .destructive) {
                                        collection.outfits.remove(at: index)
                                    }
                                }
                        }
                    }
                    .onDelete { indexSet in
                        collection.outfits.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(isPresented: $showingOutfitPicker) {
            OutfitPickerView(selectedOutfits: $selectedOutfits, onAdd: {
                collection.outfits.append(contentsOf: selectedOutfits)
            })
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
