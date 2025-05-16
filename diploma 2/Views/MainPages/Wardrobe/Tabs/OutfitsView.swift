import SwiftUI

struct OutfitsView: View {
    @ObservedObject var viewModel: OutfitViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.outfits.isEmpty {
                    Text("Нет сохраненных аутфитов")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.outfits) { outfit in
                            NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                                HStack {
                                    if let firstItem = outfit.outfitItems.first {
                                        Image(firstItem.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    VStack(alignment: .leading) {
                                        Text(outfit.name)
                                            .font(.headline)
                                        Text("\(outfit.outfitItems.count) вещей")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteOutfit)
                    }
                }
            }
            .navigationTitle("Мои аутфиты")
        }
    }

    private func deleteOutfit(at offsets: IndexSet) {
        viewModel.outfits.remove(atOffsets: offsets)
    }
}

