import SwiftUI

struct AddClothingItemView: View {
    @StateObject var viewModel = AddClothingItemViewModel()
    @State private var showEraser = false
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isErrorToast = false


    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Меню выбора гардероба
                        Group {
                            Menu {
                                ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                                    Button(action: {
                                        viewModel.selectedWardrobeName = wardrobe.name
                                        viewModel.selectedWardrobeId = wardrobe.id
                                    }) {
                                        Text(wardrobe.name)
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

                        // Фото
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

                            Button(action: {
                                viewModel.showingImagePicker.toggle()
                            }) {
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
                                    showEraser = true
                                }
                            }) {
                                ImagePicker(image: $viewModel.selectedImage)
                            }
                        }

                        // Поля ввода
                        Group {
                            CustomSelectableNavigationLink(
                                title: "Сезоны",
                                selectedItem: $viewModel.selectedSeason,
                                destination: ContentSelectionView(
                                    items: viewModel.seasons,
                                    selectedItem: $viewModel.selectedSeason
                                )
                            )

                            CustomSelectableNavigationLink(
                                title: "Категория",
                                selectedItem: $viewModel.selectedType,
                                destination: ContentSelectionView(
                                    items: viewModel.clothingTypes,
                                    selectedItem: $viewModel.selectedType
                                )
                            )

                            CustomSelectableNavigationLink(
                                title: "Бренды",
                                selectedItem: $viewModel.selectedBrand,
                                destination: ContentSelectionView(
                                    items: viewModel.brands,
                                    selectedItem: $viewModel.selectedBrand
                                )
                            )

                            CustomSelectableNavigationLink(
                                title: "Цвет",
                                selectedItem: $viewModel.selectedColor,
                                destination: ContentSelectionView(
                                    items: viewModel.colors,
                                    selectedItem: $viewModel.selectedColor
                                ),
                                showColorDot: true
                            )

                            CustomTextField(title: "Цена", text: $viewModel.price, keyboardType: .decimalPad)
                            CustomTextField(title: "Заметка", text: $viewModel.note)
                        }

                        // Кнопка сохранения
                        Button(action: {
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
                        }) {
                            Text("Сохранить")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .cornerRadius(14)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }

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
