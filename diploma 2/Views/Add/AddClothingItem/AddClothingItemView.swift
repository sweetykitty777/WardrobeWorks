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
/*import Foundation
import SwiftUI

struct AddClothingItemView: View {
    @ObservedObject var viewModel: WeeklyCalendarViewModel
    @State private var itemName: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var category: String = ""
    @State private var brand: String = ""
    @State private var tags: String = ""
    @State private var color: String = ""
    @State private var season: String = ""
    @State private var price: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var note: String = ""

    let colors = ["Красный", "Синий", "Зелёный", "Чёрный", "Белый"]
    let seasons = ["Лето", "Зима", "Осень", "Весна"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Button(action: {
                        showingImagePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text(selectedImage == nil ? "Добавить фотографию" : "Изменить фотографию")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Название")
                                .font(.headline)
                            Spacer()
                        }
                        TextField("Введите название...", text: $itemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Категория")
                                .font(.headline)
                            Spacer()
                        }
                        NavigationLink(destination: CategorySelectionView(selectedCategory: $category)) {
                            HStack {
                                Text(category.isEmpty ? "Добавить категорию" : category)
                                    .foregroundColor(category.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Бренд")
                                .font(.headline)
                            Spacer()
                        }
                        TextField("Введите бренд...", text: $brand)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Цвет")
                                .font(.headline)
                            Spacer()
                        }
                        NavigationLink(destination: ColorSelectionView(selectedColor: $color)) {
                            HStack {
                                Text(color.isEmpty ? "Добавить цвет" : color)
                                    .foregroundColor(color.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Сезон")
                                .font(.headline)
                            Spacer()
                        }
                        NavigationLink(destination: SeasonSelectionView(selectedSeason: $season)) {
                            HStack {
                                Text(season.isEmpty ? "Добавить сезон" : season)
                                    .foregroundColor(season.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Цена")
                                .font(.headline)
                            Spacer()
                        }
                        TextField("Введите цену...", text: $price)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Дата покупки")
                                .font(.headline)
                            Spacer()
                        }
                        DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                    }

                    VStack(spacing: 15) {
                        HStack {
                            Text("Заметка")
                                .font(.headline)
                            Spacer()
                        }
                        TextField("Добавить заметку...", text: $note)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Добавить вещь")
        }
    }
}

struct CategorySelectionView: View {
    @Binding var selectedCategory: String

    let categories = ["Футболка", "Брюки", "Куртка", "Платье", "Обувь"]

    var body: some View {
        List {
            ForEach(categories, id: \ .self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    HStack {
                        Text(category)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Выберите категорию")
    }
}

struct ColorSelectionView: View {
    @Binding var selectedColor: String

    let colors = ["Красный", "Синий", "Зелёный", "Чёрный", "Белый"]

    var body: some View {
        List {
            ForEach(colors, id: \ .self) { color in
                Button(action: {
                    selectedColor = color
                }) {
                    HStack {
                        Text(color)
                        Spacer()
                        if selectedColor == color {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Выберите цвет")
    }
}

struct SeasonSelectionView: View {
    @Binding var selectedSeason: String

    let seasons = ["Лето", "Зима", "Осень", "Весна"]

    var body: some View {
        List {
            ForEach(seasons, id: \ .self) { season in
                Button(action: {
                    selectedSeason = season
                }) {
                    HStack {
                        Text(season)
                        Spacer()
                        if selectedSeason == season {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Выберите сезон")
    }
}

*/
