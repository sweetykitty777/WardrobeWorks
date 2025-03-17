import SwiftUI

struct WeeklyCalendarView: View {
    @StateObject private var viewModel = WeeklyCalendarViewModel()
    @StateObject private var statsViewModel = ClothingStatsViewModel()

    @State private var posts: [Post] = [] // ✅ Добавляем состояние для постов
    @State private var showingDatePicker = false
    @State private var showingAddItemSheet = false
    @State private var showingAddOutfitSheet = false
    @State private var showingAddPostSheet = false // ✅ Добавляем флаг для постов
    @State private var showingMenu = false
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    VStack(spacing: 0) {
                        HeaderView(
                            showingDatePicker: $showingDatePicker,
                            selectedDate: $viewModel.selectedDate,
                            onDateSelected: { newDate in
                                viewModel.selectDate(newDate)
                            }
                        )

                        WeekNavigationView(viewModel: viewModel)

                        DaysScrollView(viewModel: viewModel)

                        AddOutfitButton(showingAddOutfitSheet: $showingAddOutfitSheet)

                        ClothingStatsView(viewModel: statsViewModel)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        viewModel.updateCurrentWeek()
                        statsViewModel.fetchClothingStats()
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Календарь")
                    }
                    .tag(0)

                    WardrobeTabView()
                        .tabItem {
                            Image(systemName: "tshirt")
                            Text("Гардероб")
                        }
                        .tag(1)

                    Color.clear
                        .tabItem {
                            PlusTabButton()
                        }
                        .tag(2)
                        .onAppear {
                            if !showingMenu {
                                withAnimation(.spring()) {
                                    showingMenu = true
                                }
                            }
                            selectedTab = 0 // ✅ Остаёмся на предыдущей вкладке
                        }

                    InspirationView()
                        .tabItem {
                            Image(systemName: "lightbulb")
                            Text("Вдохновение")
                        }
                        .tag(3)

                    Text("Профиль")
                        .tabItem {
                            Image(systemName: "person")
                            Text("Профиль")
                        }
                        .tag(4)
                }
            }

            if showingMenu {
                CustomMenuOverlay(
                    showingMenu: $showingMenu,
                    showingAddItemSheet: $showingAddItemSheet,
                    showingAddOutfitSheet: $showingAddOutfitSheet,
                    showingAddPostSheet: $showingAddPostSheet // ✅ Передаем флаг для постов
                )
                .offset(y: showingMenu ? 0 : UIScreen.main.bounds.height)
                .animation(.spring(), value: showingMenu)
            }
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddClothingItemView(viewModel: AddClothingItemViewModel())
        }
        .sheet(isPresented: $showingAddOutfitSheet) {
            CreateOutfitView(viewModel: OutfitViewModel())
        }
        .sheet(isPresented: $showingAddPostSheet) { // ✅ Открываем создание поста
            CreatePostView(posts: $posts) // ✅ Передаем `Binding` списка постов
        }
    }
}





/*

struct WeeklyCalendarView: View {
    @StateObject private var viewModel = WeeklyCalendarViewModel()
    
    @State private var showingDatePicker = false
    @State private var selectedDate: Date = Date()
    @State private var showingAddItemSheet = false
    @State private var showingAddOutfitSheet = false
    @State private var showingMenu = false

    var body: some View {
        ZStack {
            // ✅ Основной контент с TabView
            TabView(selection: $showingMenu) {
                VStack {
                    headerView
                    weekNavigationView
                    daysScrollView
                    addOutfitButton
                    clothingStatsView
                }

                .padding(.top, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .onAppear {
                    viewModel.updateCurrentWeek()
                    viewModel.fetchClothingStats()
                }
                .tabItem { Image(systemName: "calendar") }
                .tag(false) // По умолчанию закрыто меню

                WardrobeTabView()
                    .tabItem { Image(systemName: "tshirt") }
                    .tag(false)

                // ✅ Теперь вкладка "+" просто меняет состояние showingMenu
                Color.clear
                    .tabItem { Image(systemName: "plus.circle.fill") }
                    .tag(true) // При выборе этой вкладки открываем меню
                    .onAppear {
                        withAnimation(.spring()) {
                            showingMenu = true
                        }
                    }

                Text("Вдохновение")
                    .tabItem { Image(systemName: "lightbulb") }
                    .tag(false)

                Text("Профиль")
                    .tabItem { Image(systemName: "person") }
                    .tag(false)
            }

            // ✅ Показываем CustomMenuView, если showingMenu == true
            if showingMenu {
                CustomMenuOverlay .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddClothingItemView(viewModel: AddClothingItemViewModel())
        }
        .sheet(isPresented: $showingAddOutfitSheet) {
            // AddOutfitView(viewModel: viewModel)
        }
    }
}

struct WardrobeTabView: View {
    @State private var selectedTab: WardrobeTab = .clothes  // Выбранная вкладка
    
    var body: some View {
        VStack(spacing: 0) { // Убираем лишние отступы между элементами
            // ✅ Фиксируем TabBar в верхней части
            TabBar(selectedTab: $selectedTab)
                .background(Color(.systemBackground)) // Устанавливаем фон
                .zIndex(1) // Убедимся, что TabBar всегда сверху

            // ✅ Содержимое под TabBar
            TabContent(selectedTab: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
        .padding(.top, 10)// Убираем верхние ограничения для iOS
    }
}

// MARK: - Варианты вкладок
enum WardrobeTab: String, CaseIterable {
    case clothes = "Вещи"
    case outfits = "Аутфиты"
    case collections = "Лукбуки"
}

// MARK: - Кастомный TabBar
struct TabBar: View {
    @Binding var selectedTab: WardrobeTab
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(WardrobeTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation {
                        selectedTab = tab
                    }
                }) {
                    VStack {
                        Text(tab.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                            .fontWeight(.regular)
                        
                        // Подчеркнутый индикатор
                        Rectangle()
                            .frame(height: selectedTab == tab ? 2 : 0)
                            .foregroundColor(.gray)
                            .animation(.easeInOut, value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity) // Равномерное распределение по ширине
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Содержимое для каждой вкладки
struct TabContent: View {
    var selectedTab: WardrobeTab
    
    var body: some View {
        switch selectedTab {
        case .clothes:
            ClothesView()
        case .outfits:
            OutfitsView()
        case .collections:
            CollectionsView()
        }
    }
}

// MARK: - Контент для вкладки "Clothes"
struct ClothesView: View {
    var body: some View {
        VStack(spacing: 16) {
        }
        .padding(.top, 10)
    }
}

// MARK: - Контент для вкладки "Outfits"
struct OutfitsView: View {
    var body: some View {
        VStack {
            Text("Outfits will be displayed here")
                .font(.headline)
        }
        .padding(.top, 10)
    }
}

// MARK: - Контент для вкладки "Collections"
struct CollectionsView: View {
    var body: some View {
        VStack {
            Text("Collections will be displayed here")
                .font(.headline)
        }
        .padding(.top, 10)
    }
}
// MARK: - Subviews
private extension WeeklyCalendarView {
    /// Верхний заголовок с кнопкой выбора даты
    var headerView: some View {
        HStack {
            Spacer()
            Button(action: { showingDatePicker.toggle() }) {
                Image(systemName: "calendar")
                    .foregroundColor(.black)
                    .font(.system(size: 24))
                    .padding()
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerView
            }
        }
        .padding(.trailing, 20)
    }

    /// Выбор даты через DatePicker
    var datePickerView: some View {
        VStack {
            DatePicker("Выберите дату", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .onChange(of: selectedDate) { newDate in
                    viewModel.selectDate(newDate)
                    showingDatePicker.toggle()
                }
        }
    }

    /// Навигация по неделям
    var weekNavigationView: some View {
        HStack {
            Button(action: { viewModel.changeWeek(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
            }
            Spacer()
            Text(viewModel.weekRange)
                .fontWeight(.regular)
            Spacer()
            Button(action: { viewModel.changeWeek(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    /// Горизонтальный скролл с днями недели
    var daysScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(viewModel.currentWeek, id: \.date) { day in
                    dayView(for: day)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 100)
    }

    /// Отображение конкретного дня
    func dayView(for day: CalendarDay) -> some View {
        VStack(spacing: 6) {
            Text(day.date.formattedDayOfWeek)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("\(Calendar.current.component(.day, from: day.date))")
                .fontWeight(.semibold)
                .padding(12)
                .background(day.isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())
                .foregroundColor(day.isSelected ? .white : .black)
                .onTapGesture {
                    withAnimation { viewModel.selectDate(day.date) }
                }
        }
        .frame(width: 50)
    }

    /// Кнопка "+" для открытия CustomMenuView
    var addButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                showingMenu = true
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.largeTitle)
                
        }
    }

    /// Кнопка "Добавить Outfit"
    var addOutfitButton: some View {
        Button(action: { showingAddOutfitSheet = true }) {
            HStack {
                Text("Добавить аутфит")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Image(systemName: "plus.circle.fill")
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
           // .background(Color(red: 0.9608, green: 0.9765, blue: 0.9961))
            .cornerRadius(10)
            .foregroundColor(.blue)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    /// **Блок со статистикой одежды**
    var clothingStatsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                // Действие при нажатии на кнопку "Полная статистика"
            }) {
                Text("Полная статистика")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)

            Text("Статистика за неделю")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 20)

            HStack(spacing: 10) {
                statBox(title: "Всего вещей", value: "\(viewModel.totalItems)")
                statBox(title: "Аутфитов", value: "\(viewModel.weeklyUsage)")
                statBox(title: "Популярное", value: viewModel.mostPopularItem)
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }

    /// **Квадратики статистики**
    func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.body)
                .bold()
                .foregroundColor(.black)
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }

    /// Всплывающее меню CustomMenuView
    /// Всплывающее меню CustomMenuView как Bottom Sheet
    var CustomMenuOverlay: some View {
            ZStack {
                // ✅ Затемненный фон (по тапу закрывает меню)
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showingMenu = false
                        }
                    }
                
                VStack {
                    Spacer() // Отступ сверху (меню внизу)

                    CustomMenuView(
                        onAddClothes: {
                            showingMenu = false
                            showingAddItemSheet = true
                        },
                        onCreateOutfit: {
                            showingMenu = false
                            showingAddOutfitSheet = true
                        }
                    )
                    .frame(height: 200) // ✅ Ограниченная высота меню
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .offset(y: showingMenu ? 0 : 300) // ✅ Анимация появления
                    .transition(.move(edge: .bottom))
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }

}

*/
