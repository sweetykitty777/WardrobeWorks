import SwiftUI

/*
struct WeeklyCalendarView: View {
    @StateObject private var viewModel = WeeklyCalendarViewModel()
    @StateObject private var statsViewModel = ClothingStatsViewModel()
    @StateObject private var calendarOutfitViewModel = CalendarOutfitViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()

    @State private var posts: [Post] = []
    @State private var showingDatePicker = false
    @State private var showingAddItemSheet = false
    @State private var showingAddOutfitSheet = false
    @State private var showingAddPostSheet = false
    @State private var showingScheduleOutfit = false
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
                      //  DaysScrollView(viewModel: viewModel)

                        ScheduledOutfitView(
                            scheduledOutfit: $viewModel.selectedScheduledOutfit,
                            showingAddOutfitSheet: $showingScheduleOutfit
                        )

                        ClothingStatsView(viewModel: statsViewModel)
                        // Spacer() — убран, чтобы не было пустоты
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        viewModel.updateCurrentMonth()
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
                            if (!showingMenu) {
                                withAnimation(.spring()) {
                                    showingMenu = true
                                }
                            }
                            selectedTab = 0
                        }

                    InspirationView()
                        .tabItem {
                            Image(systemName: "lightbulb")
                            Text("Вдохновение")
                        }
                        .tag(3)

                    UserProfileView()
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
                    showingAddPostSheet: $showingAddPostSheet
                )
                .offset(y: showingMenu ? 0 : UIScreen.main.bounds.height)
                .animation(.spring(), value: showingMenu)
            }
        }
        .background(Color.white.ignoresSafeArea()) // Белый фон для всего экрана
        .sheet(isPresented: $showingAddItemSheet) {
            AddClothingItemView(viewModel: AddClothingItemViewModel())
        }
        .sheet(isPresented: $showingAddOutfitSheet) {
            CreateOutfitView(viewModel: outfitViewModel)
        }
        .sheet(isPresented: $showingAddPostSheet) {
            CreatePostView(posts: $posts)
        }
        .sheet(isPresented: $showingScheduleOutfit) {
            ScheduleOutfitView(
                viewModel: calendarOutfitViewModel,
                date: viewModel.selectedDate,
                outfits: outfitViewModel.outfits
            )
        }
    }
} */




struct WeeklyCalendarView: View {
    @StateObject private var viewModel = WeeklyCalendarViewModel()
    @StateObject private var statsViewModel = ClothingStatsViewModel()
    @StateObject private var calendarOutfitViewModel = CalendarOutfitViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    @StateObject private var wardrobeViewModel = WardrobeViewModel()

    @State private var posts: [Post] = []
    @State private var showingDatePicker = false
    @State private var showingAddItemSheet = false
    @State private var showingAddOutfitSheet = false
    @State private var showingShareAccessSheet = false
    @State private var showingAddPostSheet = false
    @State private var showingScheduleOutfit = false
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
                        Button(action: {
                            showingShareAccessSheet = true
                        }) {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.blue)
                        }


                        WeekNavigationView(viewModel: viewModel)
                        DaysScrollView(viewModel: viewModel)

                        ScheduledOutfitView(
                            scheduledOutfit: $viewModel.selectedScheduledOutfit,
                            showingAddOutfitSheet: $showingScheduleOutfit
                        )

                        ClothingStatsView(viewModel: statsViewModel)
                        
                        

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        viewModel.updateCurrentWeek()
                        statsViewModel.fetchClothingStats()
                        wardrobeViewModel.fetchWardrobes()
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
                            if (!showingMenu) {
                                withAnimation(.spring()) {
                                    showingMenu = true
                                }
                            }
                            selectedTab = 0
                        }

                    InspirationView()
                        .tabItem {
                            Image(systemName: "lightbulb")
                            Text("Вдохновение")
                        }
                        .tag(3)

                    UserProfileView()
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
                    showingAddPostSheet: $showingAddPostSheet
                )
                .offset(y: showingMenu ? 0 : UIScreen.main.bounds.height)
                .animation(.spring(), value: showingMenu)
            }
        }
        .background(Color.white.ignoresSafeArea()) // Белый фон для всего экрана
        .sheet(isPresented: $showingAddItemSheet) {
            if let wardrobeId = wardrobeViewModel.wardrobes.first?.id {
                AddClothingItemView(wardrobeId: wardrobeId)
            }
        }
        .sheet(isPresented: $showingAddOutfitSheet) {
            CreateOutfitView(viewModel: outfitViewModel)
        }
        .sheet(isPresented: $showingAddPostSheet) {
            CreatePostView(posts: $posts)
        }
        .sheet(isPresented: $showingScheduleOutfit) {
            ScheduleOutfitView(
                viewModel: calendarOutfitViewModel,
                date: viewModel.selectedDate,
                outfits: outfitViewModel.outfits
            )
        }
    }
}


struct ScheduledOutfitView: View {
    @Binding var scheduledOutfit: ScheduledOutfit?
    @Binding var showingAddOutfitSheet: Bool
    @State private var isEditingNote = false
    @State private var editedNote: String = ""

    var body: some View {
        if let scheduled = scheduledOutfit {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if isEditingNote {
                        TextField("Заметка", text: Binding(
                            get: { editedNote },
                            set: {
                                if $0.count <= 20 {
                                    editedNote = $0
                                }
                            })
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            scheduledOutfit?.eventNote = editedNote
                            isEditingNote = false
                        }
                    } else if let note = scheduled.eventNote, !note.isEmpty {
                        Text(note)
                            .font(.headline)
                    } else {
                        Text("Без заметки")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: {
                            editedNote = scheduled.eventNote ?? ""
                            isEditingNote.toggle()
                        }) {
                            Image(systemName: "pencil")
                        }
                        Button(action: {
                            showingAddOutfitSheet = true
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Button(role: .destructive) {
                            scheduledOutfit = nil
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }

                OutfitCard(outfit: scheduled.outfit)
            }
            .padding(.horizontal)
        } else {
            AddOutfitButton(showingAddOutfitSheet: $showingAddOutfitSheet)
        }
    }
}

