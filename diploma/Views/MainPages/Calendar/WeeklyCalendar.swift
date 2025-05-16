import SwiftUI

struct WeeklyCalendarView: View {
    @StateObject private var viewModel = WeeklyCalendarViewModel()
    @StateObject private var calendarOutfitViewModel = CalendarOutfitViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    @StateObject private var inspirationViewModel = InspirationViewModel()
    @StateObject var statsViewModel = FullStatsViewModel()
    @StateObject private var clothesViewModel = ClothesViewModel() 

    @State private var posts: [Post] = []
    @State private var showingDatePicker = false
    @State private var showingAddItemSheet = false
    @State private var showingAddOutfitSheet = false
    @State private var showingAddPostSheet = false
    @State private var showingScheduleOutfit = false
    @State private var showingShareAccessSheet = false
    @State private var showingMenu = false
    @State private var selectedTab: Int = 0
    @State private var previousTab: Int = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                calendarTab
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Календарь")
                    }
                    .tag(0)

                NavigationStack {
                    WardrobeTabView()
                } .applyNavigationRouter()
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

                NavigationStack {
                    InspirationView()
                }.applyNavigationRouter()
                    .tabItem {
                        Image(systemName: "lightbulb")
                        Text("Вдохновение")
                    }
                    .tag(3)

                NavigationStack {
                    UserProfileView()
                }.applyNavigationRouter()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Профиль")
                    }
                    .tag(4)
            }

            CustomMenuOverlay(
                showingMenu: $showingMenu,
                showingAddItemSheet: $showingAddItemSheet,
                showingAddOutfitSheet: $showingAddOutfitSheet,
                showingAddPostSheet: $showingAddPostSheet
            )
            .offset(y: showingMenu ? 0 : UIScreen.main.bounds.height)
            .animation(.spring(), value: showingMenu)
            .zIndex(1)
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 2 {
                showingMenu = true
                selectedTab = previousTab
            } else {
                previousTab = newValue
            }
        }
        .background(Color.white.ignoresSafeArea())
        .fullScreenCover(isPresented: $showingAddItemSheet) {
            NavigationStack {
                AddClothingItemView(
                    viewModel: AddClothingItemViewModel(),
                    clothesViewModel: clothesViewModel
                )
            }
        }

        .fullScreenCover(isPresented: $showingAddOutfitSheet) {
            NavigationStack {
                CreateOutfitView(
                    wardrobeId: nil, // <-- передаём nil, если не хотим фетчить заранее
                    onSave: {
                        showingAddOutfitSheet = false
                  //      outfitViewModel.fetchOutfits()
                    }
                )
            }
        }



        .fullScreenCover(isPresented: $showingAddPostSheet) {
            NavigationStack {
                CreatePostView(posts: $posts, outfitViewModel: outfitViewModel)
            }
        }
        .sheet(isPresented: $showingScheduleOutfit) {
            NavigationStack {
                ScheduleOutfitView(
                    viewModel: ScheduleOutfitViewModel(date: viewModel.selectedDate),
                    onSuccess: {
                        viewModel.updateCurrentWeek()
                        statsViewModel.refreshPlannedLast7Days()
                    }
                )
            }
        }
        .sheet(isPresented: $showingShareAccessSheet) {
            NavigationStack {
                if let calendar = viewModel.calendar {
                    CalendarPrivacyView(
                        viewModel: CalendarPrivacyViewModel(
                            calendarId: calendar.id,
                            initialPrivacy: calendar.isPrivate
                        )
                    )
                } else {
                    ProgressView("Загрузка...")
                        .padding()
                        .onAppear {
                            viewModel.fetchCalendar()
                        }
                }
            }
        }
        .onAppear {
            viewModel.fetchCalendar {
                viewModel.fetchScheduledOutfits { _ in
                    viewModel.updateCurrentWeek()
                }
            }
     //       statsViewModel.fetchClothingStats()
        }
    }

    private var calendarTab: some View {
        WeeklyCalendarTabContent(
            viewModel: viewModel,
            statsViewModel: statsViewModel,
            inspirationViewModel: inspirationViewModel,
            showingDatePicker: $showingDatePicker,
            showingScheduleOutfit: $showingScheduleOutfit,
            showingShareAccessSheet: $showingShareAccessSheet
        )
    }
}
