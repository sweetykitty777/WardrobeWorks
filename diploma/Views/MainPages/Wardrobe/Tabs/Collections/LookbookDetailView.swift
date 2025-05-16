import SwiftUI

struct LookbookDetailView: View {
    let lookbook: LookbookResponse
    let wardrobeId: Int?
    
    @Environment(\.dismiss) private var dismiss
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
                        if !lookbook.description.isEmpty {
                            Text(lookbook.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }

                        if viewModel.outfits.isEmpty {
                            Text(viewModel.errorMessage == nil ? "Аутфиты не найдены" : "Ошибка: \(viewModel.errorMessage!)")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.outfits, id: \.self) { outfit in
                                    OutfitCardView(outfit: outfit)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                withAnimation(.easeInOut) {
                                                    viewModel.removeOutfit(outfitId: outfit.id)
                                                }
                                            } label: {
                                                Label("Удалить из лукбука", systemImage: "trash")
                                            }
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding()
                            .animation(.easeInOut(duration: 0.3), value: viewModel.outfits)
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                viewModel.lookbookId = lookbook.id
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
                    ) { _ in
                        selectedOutfits = []
                        showingOutfitPicker = false
                    }
                }
            }
        }
}
