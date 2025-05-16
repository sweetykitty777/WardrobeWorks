import SwiftUI

struct AddClothingItemView: View {
    @StateObject var viewModel = AddClothingItemViewModel()
    @ObservedObject var clothesViewModel: ClothesViewModel 

    @State private var showEraser = false
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isErrorToast = false


    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        wardrobePicker
                        imageSection
                        formFields
                        saveButton
                    }
                    .padding()
                }

                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: toastMessage, isError: isErrorToast)
                            .padding(.bottom, 40)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.3), value: showToast)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Добавить вещь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.fetchWardrobes()
                viewModel.fetchContentData()
            }
            .fullScreenCover(isPresented: $showEraser) {
                if let image = viewModel.selectedImage {
                    BackgroundEraserView(inputImage: image) { edited in
                        viewModel.selectedImage = edited
                    }
                }
            }
        }
    }

    private var wardrobePicker: some View {
        Menu {
            ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                Button(wardrobe.name) {
                    viewModel.selectedWardrobeName = wardrobe.name
                    viewModel.selectedWardrobeId = wardrobe.id
                }
            }
        } label: {
            HStack {
                Text(viewModel.selectedWardrobeName)
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    private var imageSection: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        showEraser = true
                    }
            }

            Button {
                viewModel.showingImagePicker.toggle()
            } label: {
                HStack {
                    Image(systemName: "photo")
                    Text(viewModel.selectedImage == nil ? "Добавить фотографию" : "Изменить фотографию")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                }
                .padding()
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .sheet(isPresented: $viewModel.showingImagePicker, onDismiss: {
                if viewModel.selectedImage != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showEraser = true
                    }
                }
            }) {
                ImagePicker(image: $viewModel.selectedImage)
            }
        }
    }

    private var formFields: some View {
        Group {
            NavigationLink(destination: ContentSelectionView(items: viewModel.seasons, selectedItem: $viewModel.selectedSeason)) {
                CustomSelectableRow(title: "Сезоны", selectedItem: viewModel.selectedSeason)
            }
            NavigationLink(destination: ContentSelectionView(items: viewModel.clothingTypes, selectedItem: $viewModel.selectedType)) {
                CustomSelectableRow(title: "Категория", selectedItem: viewModel.selectedType)
            }
            NavigationLink(destination: ContentSelectionView(items: viewModel.brands, selectedItem: $viewModel.selectedBrand)) {
                CustomSelectableRow(title: "Бренды", selectedItem: viewModel.selectedBrand)
            }
            NavigationLink(destination: ContentSelectionView(items: viewModel.colors, selectedItem: $viewModel.selectedColor)) {
                CustomSelectableRow(title: "Цвет", selectedItem: viewModel.selectedColor, showColorDot: true)
            }

            CustomTextField(title: "Цена", text: $viewModel.price, keyboardType: .decimalPad, characterLimit: InputLimits.priceMaxLength)
            CustomTextField(title: "Заметка", text: $viewModel.note, characterLimit: InputLimits.noteMaxLength)
        }
    }

    private var saveButton: some View {
        Button {
            guard let wardrobeId = viewModel.selectedWardrobeId else {
                toastMessage = "Гардероб не выбран"
                isErrorToast = true
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showToast = false
                }
                return
            }

            viewModel.saveItem(wardrobeId: wardrobeId) { success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        clothesViewModel.fetchClothes(for: wardrobeId)
                    }
                    viewModel.resetForm()
                    toastMessage = "Вещь успешно добавлена"
                    isErrorToast = false
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    toastMessage = "Не удалось сохранить вещь"
                    isErrorToast = true
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showToast = false
                    }
                }
            }
        } label: {
            Text(viewModel.isSaving ? "Сохранение..." : "Сохранить")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(viewModel.isSaving ? Color.gray : Color.blue)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .disabled(viewModel.isSaving)
    }
}
