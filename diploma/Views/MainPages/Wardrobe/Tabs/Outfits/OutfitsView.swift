import SwiftUI


struct OutfitsView: View {
    @ObservedObject var viewModel: OutfitViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.outfits.indices, id: \.self) { index in
                        NavigationLink(destination: OutfitDetailView(outfit: viewModel.outfits[index])) {
                            OutfitCard(outfit: viewModel.outfits[index])
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.outfits.remove(atOffsets: indexSet)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}


