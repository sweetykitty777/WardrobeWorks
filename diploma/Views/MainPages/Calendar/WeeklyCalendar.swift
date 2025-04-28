import SwiftUI

struct WeeklyCalendarView: View {
    @StateObject private var viewModel = WeeklyCalendarViewModel()
    @StateObject private var statsViewModel = ClothingStatsViewModel()
    @StateObject private var calendarOutfitViewModel = CalendarOutfitViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    @StateObject private var inspirationViewModel = InspirationViewModel()

    @State private var posts: [Post] = []
    @State private var showingDatePicker = false
    @State private var showingAddItemSheet = false
    @State private var showingAddOutfitSheet = false
    @State private var showingAddPostSheet = false
    @State private var showingScheduleOutfit = false
    @State private var showingShareAccessSheet = false
    @State private var showingMenu = false
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    
                    NavigationView {
                        VStack(spacing: 0) {
                            ScrollView {
                                VStack(spacing: 16) {
                                    
                                    HeaderView(
                                        showingDatePicker: $showingDatePicker,
                                        selectedDate: $viewModel.selectedDate,
                                        onDateSelected: { newDate in
                                            viewModel.selectDate(newDate)
                                        },
                                        onShareAccessTapped: {
                                            showingShareAccessSheet = true
                                        }
                                    )
                                    
                                    WeekNavigationView(viewModel: viewModel)
                                    DaysScrollView(viewModel: viewModel)
                                    
                                    let scheduledVM = ScheduledOutfitViewModel(
                                        scheduledOutfit: viewModel.selectedScheduledOutfit,
                                        onDelete: {
                                            viewModel.updateCurrentWeek()
                                        }
                                    )
                                    ScheduledOutfitView(
                                        viewModel: scheduledVM,
                                        showingAddOutfitSheet: $showingScheduleOutfit
                                    )
                                    
                                    ClothingStatsView(viewModel: statsViewModel)
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Поиск календарей других пользователей")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        TextField("Введите имя пользователя...", text: $inspirationViewModel.searchText)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal)
                                            .submitLabel(.search)
                                            .onSubmit {
                                                inspirationViewModel.searchUsers()
                                            }
                                        
                                        if !inspirationViewModel.searchResults.isEmpty {
                                            ForEach(inspirationViewModel.searchResults) { user in
                                                NavigationLink(destination: UserCalendarView(userId: user.id)) {
                                                    HStack(spacing: 12) {
                                                        if let avatar = user.avatar {
                                                            RemoteImageView(
                                                                urlString: avatar,
                                                                cornerRadius: 20,
                                                                width: 40,
                                                                height: 40
                                                            )
                                                        } else {
                                                            Image(systemName: "person.crop.circle.fill")
                                                                .resizable()
                                                                .frame(width: 40, height: 40)
                                                                .foregroundColor(.gray)
                                                        }
                                                        VStack(alignment: .leading) {
                                                            Text("@\(user.username)")
                                                                .fontWeight(.semibold)
                                                            if let bio = user.bio {
                                                                Text(bio)
                                                                    .font(.caption)
                                                                    .foregroundColor(.secondary)
                                                            }
                                                        }
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .navigationBarHidden(true)
                        .onAppear {
                            viewModel.fetchCalendar {
                                viewModel.fetchScheduledOutfits { _ in
                                    viewModel.updateCurrentWeek()
                                }
                            }
                            statsViewModel.fetchClothingStats()
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Календарь")
                    }
                    .tag(0)
                    
                    NavigationView {
                        WardrobeTabView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
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
                            showingMenu = true
                            selectedTab = 0
                        }
                    
                    NavigationView {
                        InspirationView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Image(systemName: "lightbulb")
                        Text("Вдохновение")
                    }
                    .tag(3)
                    
                    NavigationView {
                        UserProfileView()
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        Image(systemName: "person")
                        Text("Профиль")
                    }
                    .tag(4)
                }
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
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showingAddItemSheet) {
            AddClothingItemView(viewModel: AddClothingItemViewModel())
        }
        .sheet(isPresented: $showingAddOutfitSheet) {
            CreateOutfitView(viewModel: outfitViewModel)
        }
        .sheet(isPresented: $showingAddPostSheet) {
            CreatePostView(posts: $posts, outfitViewModel: outfitViewModel)
        }
        .sheet(isPresented: $showingScheduleOutfit) {
            ScheduleOutfitView(
                viewModel: ScheduleOutfitViewModel(date: viewModel.selectedDate),
                onSuccess: {
                    viewModel.updateCurrentWeek()
                }
            )
        }
        .sheet(isPresented: $showingShareAccessSheet) {
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
}
