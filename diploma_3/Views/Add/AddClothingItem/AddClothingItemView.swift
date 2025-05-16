import SwiftUI

struct AddClothingItemView: View {
    @StateObject var viewModel = AddClothingItemViewModel()

    @State private var showEraser = false // ✅ Флаг показа редактора фона
    let wardrobeId: Int // Add wardrobe ID parameter

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                showEraser = true // ✅ Нажатие открывает редактор фона
                            }
                    }

                    Button(action: {
                        viewModel.showingImagePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text(viewModel.selectedImage == nil ? "Добавить фотографию" : "Изменить фотографию")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $viewModel.showingImagePicker, onDismiss: {
                        if viewModel.selectedImage != nil {
                            showEraser = true // ✅ После выбора сразу переходим к стиранию
                        }
                    }) {
                        ImagePicker(image: $viewModel.selectedImage)
                    }

                    // Остальные поля...
                    CustomTextField(title: "Название", text: $viewModel.itemName)
                    CustomNavigationLink(title: "Категория", value: viewModel.category, destination: CategorySelectionView(selectedCategory: $viewModel.category))
                    CustomTextField(title: "Бренд", text: $viewModel.brand)
                    CustomNavigationLink(title: "Цвет", value: viewModel.color, destination: ColorSelectionView(selectedColor: $viewModel.color))
                    CustomNavigationLink(title: "Сезон", value: viewModel.season, destination: SeasonSelectionView(selectedSeason: $viewModel.season))
                    CustomTextField(title: "Цена", text: $viewModel.price, keyboardType: .decimalPad)
                    CustomTextField(title: "Заметка", text: $viewModel.note)

                    Button(action: {
                        viewModel.saveClothingItem(wardrobeId: wardrobeId) {
                            // Handle completion
                            print("Item saved successfully")
                        }
                    }) {
                        Text("Сохранить")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Добавить вещь")
        }
        // ✅ Показываем экран стирания фона
        .fullScreenCover(isPresented: $showEraser) {
            if let image = viewModel.selectedImage {
                BackgroundEraserView(inputImage: image) { edited in
                    viewModel.selectedImage = edited
                }
            }
        }
    }
}

/*
struct AddClothingItemView: View {
    @StateObject var viewModel = AddClothingItemViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Button(action: {
                        viewModel.showingImagePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text(viewModel.selectedImage == nil ? "Добавить фотографию" : "Изменить фотографию")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $viewModel.showingImagePicker) {
                        ImagePicker(image: $viewModel.selectedImage)
                    }

                    CustomTextField(title: "Название", text: $viewModel.itemName)
                    
                    CustomNavigationLink(title: "Категория", value: viewModel.category, destination: CategorySelectionView(selectedCategory: $viewModel.category))

                    CustomTextField(title: "Бренд", text: $viewModel.brand)
                    
                    CustomNavigationLink(title: "Цвет", value: viewModel.color, destination: ColorSelectionView(selectedColor: $viewModel.color))
                    
                    CustomNavigationLink(title: "Сезон", value: viewModel.season, destination: SeasonSelectionView(selectedSeason: $viewModel.season))
                    
                    CustomTextField(title: "Цена", text: $viewModel.price, keyboardType: .decimalPad)

                    /*VStack(spacing: 15) {
                        HStack {
                            Text("Дата покупки").font(.headline)
                            Spacer()
                        }
                        DatePicker("", selection: $viewModel.purchaseDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                    }*/

                    CustomTextField(title: "Заметка", text: $viewModel.note)

                    Button(action: viewModel.saveClothingItem) {
                        Text("Сохранить")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Добавить вещь")
        }
    }
}*/
