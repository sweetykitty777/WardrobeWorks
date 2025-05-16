import SwiftUI

struct ClothingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ClothingDetailViewModel

    init(item: ClothItem) {
        _viewModel = StateObject(wrappedValue: ClothingDetailViewModel(item: item))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isEditing {
                    VStack(alignment: .leading, spacing: 16) {
                        CustomSelectableNavigationLink(
                            title: "Категория",
                            selectedItem: $viewModel.selectedType,
                            items: viewModel.clothingTypes
                        )
                        CustomSelectableNavigationLink(
                            title: "Бренд",
                            selectedItem: $viewModel.selectedBrand,
                            items: viewModel.brands
                        )

                        CustomSelectableNavigationLink(
                            title: "Цвет",
                            selectedItem: $viewModel.selectedColor,
                            items: viewModel.colors,
                            showColorDot: true
                        )

                        CustomSelectableNavigationLink(
                            title: "Сезон",
                            selectedItem: $viewModel.selectedSeason,
                            items: viewModel.seasons
                        )

                        CustomTextField(title: "Цена", text: $viewModel.price, keyboardType: .decimalPad)
                        CustomTextField(title: "Описание", text: $viewModel.description)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                } else {
                    ClothingDetailContentView(item: viewModel.editableItem)
                }

                if !viewModel.outfits.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Аутфиты с этой вещью")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.outfits, id: \.id) { outfit in
                                    NavigationLink(value: outfit) {
                                        SimpleOutfitCard(outfit: outfit)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Button(viewModel.isEditing ? "Отменить редактирование" : "Редактировать") {
                    if !viewModel.isEditing {
                        viewModel.loadContent()
                    }
                    viewModel.isEditing.toggle()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                if viewModel.isEditing {
                    Button(action: {
                        viewModel.saveChanges {
                            // Например, выйти из режима редактирования:
                            viewModel.isEditing = false
                        }
                    }) {
                        Text(viewModel.isSaving ? "Сохранение..." : "Сохранить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.isSaving)
                    .padding(.horizontal)
                }


                Button(role: .destructive) {
                    viewModel.deleteClothingItem { success in
                        if success {
                            dismiss()
                        } else {
                            viewModel.alertMessage = "Не удалось удалить"
                            viewModel.showAlert = true
                        }
                    }
                } label: {
                    Text("Удалить вещь")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("Ок", role: .cancel) {}
        }
        .onAppear {
            viewModel.fetchOutfits()
        }
    }
}
