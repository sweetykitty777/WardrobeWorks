import SwiftUI

struct OutfitsView: View {
    @ObservedObject var viewModel: OutfitViewModel
    var wardrobeId: Int

    @State private var showingCreateOutfitSheet = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.outfits) { outfit in
                            NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                                OutfitCard(outfit: outfit)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }

                Divider()

                Button(action: {
                    showingCreateOutfitSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить новый аутфит")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchOutfits(for: wardrobeId)
            }
        }
        .sheet(isPresented: $showingCreateOutfitSheet) {
            CreateOutfitView(viewModel: viewModel)
        }
    }
}
