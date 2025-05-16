import SwiftUI

struct OutfitPickerView: View {
    let wardrobeId: Int
    let lookbookId: Int
    @Binding var selectedOutfits: [OutfitResponse]
    var onAdd: ([OutfitResponse]) -> Void

    @StateObject private var viewModel = OutfitViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.outfits.isEmpty && !isLoading {
                Spacer()
                Text("Нет доступных аутфитов")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.outfits, id: \.id) { outfit in
                            ZStack(alignment: .topTrailing) {
                                VStack {
                                    SimpleOutfitCard(outfit: outfit)
                                        .frame(height: 180)
                                        .background(selectedOutfits.contains(where: { $0.id == outfit.id }) ? Color.blue.opacity(0.1) : Color.white)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedOutfits.contains(where: { $0.id == outfit.id }) ? Color.blue : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    toggleSelection(of: outfit)
                                }

                                if selectedOutfits.contains(where: { $0.id == outfit.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .offset(x: -8, y: 8)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }

            Divider()

            Button(action: {
                addSelectedOutfits()
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                } else {
                    Text("Добавить выбранные (\(selectedOutfits.count))")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
            }
            .background(selectedOutfits.isEmpty || isLoading ? Color.gray.opacity(0.5) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .disabled(selectedOutfits.isEmpty || isLoading)
        }
        .navigationTitle("Выбрать аутфиты")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.fetchOutfits(for: wardrobeId)
        }
    }

    private func toggleSelection(of outfit: OutfitResponse) {
        if let index = selectedOutfits.firstIndex(where: { $0.id == outfit.id }) {
            selectedOutfits.remove(at: index)
        } else {
            selectedOutfits.append(outfit)
        }
    }

    private func addSelectedOutfits() {
        guard !selectedOutfits.isEmpty else { return }
        isLoading = true

        let dispatchGroup = DispatchGroup()

        for outfit in selectedOutfits {
            dispatchGroup.enter()
            WardrobeService.shared.addOutfit(to: lookbookId, outfitId: outfit.id) { result in
                switch result {
                case .success:
                    print("Успешно добавили аутфит \(outfit.id) в лукбук")
                case .failure(let error):
                    print("Ошибка добавления аутфита \(outfit.id):", error.localizedDescription)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            isLoading = false
            onAdd(selectedOutfits)
            dismiss()
        }
    }
}
