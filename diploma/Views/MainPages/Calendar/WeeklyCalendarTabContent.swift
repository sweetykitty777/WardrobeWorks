import SwiftUI

struct WeeklyCalendarTabContent: View {
    @ObservedObject var viewModel: WeeklyCalendarViewModel
    @ObservedObject var statsViewModel: FullStatsViewModel
    @ObservedObject var inspirationViewModel: InspirationViewModel

    @Binding var showingDatePicker: Bool
    @Binding var showingScheduleOutfit: Bool
    @Binding var showingShareAccessSheet: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
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
                    }
                    .padding(.horizontal)

                    WeekNavigationView(viewModel: viewModel)
                    DaysScrollView(viewModel: viewModel)

                    let scheduledVM = ScheduledOutfitViewModel(
                        scheduledOutfit: viewModel.selectedScheduledOutfit,
                        onDelete: {
                            viewModel.updateCurrentWeek()
                            statsViewModel.refreshPlannedLast7Days()
                        }
                    )
                    ScheduledOutfitView(
                        viewModel: scheduledVM,
                        showingAddOutfitSheet: $showingScheduleOutfit
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        if let planned = statsViewModel.plannedStats7Days {
                            statPreviewCard(
                                title: "Запланировано аутфитов за 7 дней",
                                value: planned.outfitsNumber
                            )
                            .padding(.horizontal)
                        }

                        NavigationLink(destination: FullStatsView(viewModel: statsViewModel)) {
                            Text("Перейти ко всей статистике")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                                .padding(.top, 4)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    CalendarSearchSectionView(inspirationViewModel: inspirationViewModel)
                        .padding(.top, 8)
                }
            }
        }
    }

    private func statPreviewCard(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text("\(value)")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
