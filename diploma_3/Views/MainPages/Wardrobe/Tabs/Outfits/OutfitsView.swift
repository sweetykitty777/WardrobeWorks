import SwiftUI

struct OutfitsView: View {
    @ObservedObject var viewModel: OutfitViewModel

    // Две колонки
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.outfits.indices, id: \.self) { index in
                        NavigationLink(destination: OutfitDetailView(outfit: viewModel.outfits[index])) {
                            OutfitCard(outfit: viewModel.outfits[index])
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .navigationBarHidden(true)
        }
    }
}
