import SwiftUI

struct LookbookDetailView: View {
    let lookbook: LookbookResponse
    let wardrobeId: Int?
    @StateObject private var viewModel = LookbookDetailViewModel()

    @State private var showingOutfitPicker = false
    @State private var selectedOutfits: [OutfitResponse] = []

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    // Описание лукбука
                    if !lookbook.description.isEmpty {
                        Text(lookbook.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if viewModel.outfits.isEmpty {
                        Text(viewModel.errorMessage == nil ? "Аутфиты не найдены" : "Ошибка: \(viewModel.errorMessage!)")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.outfits, id: \.id) { outfit in
                                OutfitCard(outfit: outfit)
                            }
                        }
                        .padding()
                    }
                }
            }

            if wardrobeId != nil {
                Divider()
                Button(action: {
                    showingOutfitPicker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить аутфиты")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .navigationTitle(lookbook.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchOutfits(in: lookbook.id)
        }
        .onChange(of: showingOutfitPicker) { newValue in
            if !newValue {
                viewModel.fetchOutfits(in: lookbook.id)
            }
        }
        .sheet(isPresented: $showingOutfitPicker) {
            if let wardrobeId = wardrobeId {
                OutfitPickerView(
                    wardrobeId: wardrobeId,
                    lookbookId: lookbook.id,
                    selectedOutfits: $selectedOutfits
                ) { selected in
                    selectedOutfits = []
                    showingOutfitPicker = false
                }
            }
        }
    }
}
