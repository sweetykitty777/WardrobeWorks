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
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView("Загрузка аутфитов...")
                            .padding()
                    } else if viewModel.outfits.isEmpty {
                        Text("У вас пока нет аутфитов")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.outfits) { outfit in
                                NavigationLink(value: outfit) {
                                    OutfitCardView(outfit: outfit)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
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
            .onChange(of: wardrobeId) { newId in
                viewModel.fetchOutfits(for: newId)
            }
            .navigationDestination(for: OutfitResponse.self) { outfit in
                OutfitDetailView(outfit: outfit)
            }
        }

        .fullScreenCover(isPresented: $showingCreateOutfitSheet) {
            NavigationStack {
                CreateOutfitView(
                    wardrobeId: wardrobeId,
                    onSave: {
                        // Закрыть sheet и обновить список
                        showingCreateOutfitSheet = false
                        viewModel.fetchOutfits(for: wardrobeId)
                    }
                )
            }
        }
    }
}
