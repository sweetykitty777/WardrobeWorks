import SwiftUI

struct CreateOutfitView: View {
    let wardrobeId: Int?
    let onSave: () -> Void

    @StateObject private var viewModel = CreateOutfitViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var canvasSize: CGSize = .zero
    @State private var showWardrobeResetAlert = false
    @State private var wardrobeToSwitch: UsersWardrobe? = nil

    var body: some View {
        VStack(spacing: 16) {
            wardrobeMenu

            canvasView
                .frame(height: 400)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)

            actionButtons

            Spacer()
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Создать аутфит")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $viewModel.showingWardrobe) {
            if let selectedId = viewModel.selectedWardrobeId {
                WardrobeSelectionView(
                    selectedItems: $viewModel.placedItems,
                    wardrobeId: selectedId,
                    imageURLs: $viewModel.imageURLsByClothId,
                    canvasSize: canvasSize
                )
            } else {
                Text("Пожалуйста, выберите гардероб")
            }
        }
        .onAppear {
            if let id = wardrobeId {
                viewModel.selectWardrobeById(id)
            } else {
                viewModel.fetchWardrobes()
            }
        }
        .overlay(
            Group {
                if viewModel.showToast {
                    ToastView(message: viewModel.toastMessage)
                        .transition(.opacity)
                        .padding()
                }
            }
        )
    }

    private var wardrobeMenu: some View {
        Menu {
            ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                Button(wardrobe.name) {
                    if !viewModel.placedItems.isEmpty,
                       wardrobe.id != viewModel.selectedWardrobeId {
                        wardrobeToSwitch = wardrobe
                        showWardrobeResetAlert = true
                    } else {
                        viewModel.selectWardrobe(wardrobe)
                    }
                }
            }
        } label: {
            HStack {
                Text(viewModel.selectedWardrobeName)
                    .foregroundColor(viewModel.selectedWardrobeId == nil ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
        }
        .alert(isPresented: $showWardrobeResetAlert) {
            Alert(
                title: Text("Сменить гардероб?"),
                message: Text("При смене гардероба все вещи с холста будут удалены."),
                primaryButton: .destructive(Text("Сменить")) {
                    if let wardrobe = wardrobeToSwitch {
                        viewModel.placedItems.removeAll()
                        viewModel.imageURLsByClothId.removeAll()
                        viewModel.selectWardrobe(wardrobe)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var canvasView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                    .onAppear {
                        canvasSize = geometry.size
                    }

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

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.showingWardrobe = true
            } label: {
                Label("Добавить вещи", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1)
                    .padding(.horizontal)
            }

            Button {
                viewModel.saveOutfit {
                    onSave()
                    dismiss()
                }
            } label: {
                Text(viewModel.isSaving ? "Сохранение..." : "Сохранить аутфит")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        (viewModel.isSaving || viewModel.placedItems.isEmpty)
                        ? Color.gray.opacity(0.5)
                        : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(viewModel.isSaving || viewModel.placedItems.isEmpty)
        }
    }
}
