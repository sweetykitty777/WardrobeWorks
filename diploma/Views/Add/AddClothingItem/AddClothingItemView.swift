import SwiftUI

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

                    VStack(spacing: 15) {
                        HStack {
                            Text("Дата покупки").font(.headline)
                            Spacer()
                        }
                        DatePicker("", selection: $viewModel.purchaseDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                    }

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
}
