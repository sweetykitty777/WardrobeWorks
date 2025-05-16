import SwiftUI

struct EditOutfitView: View {
    let outfitId: Int
    @StateObject private var viewModel = EditOutfitViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {

            canvasView
                .frame(height: 400)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)

            Button(action: {
                viewModel.saveChanges(outfitId: outfitId) {
                    dismiss()
                }
            }) {
                Text(viewModel.isSaving ? "Сохранение..." : "Сохранить изменения")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isSaving ? Color.gray.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(viewModel.isSaving)

            Spacer()
        }
        .navigationTitle("Редактировать аутфит")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
        }
        .onAppear {
            viewModel.loadOutfit(id: outfitId)
        }
    }

    private var canvasView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear

                ForEach($viewModel.placedItems, id: \.clothId) { $item in
                    if let imageURL = viewModel.imageURLsByClothId[item.clothId] {
                        DraggableItem(
                            item: $item,
                            imageURL: imageURL,
                            canvasSize: geometry.size,
                            onDelete: {
                                viewModel.removeItem(item)
                            }
                        )
                    }
                }
            }
        }
    }
}
