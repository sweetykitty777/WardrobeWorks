import SwiftUI

struct UserCalendarView: View {
    @StateObject private var viewModel: UserCalendarViewModel
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @Environment(\.dismiss) private var dismiss

    init(userId: Int) {
        _viewModel = StateObject(wrappedValue: UserCalendarViewModel(userId: userId))
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(datesInCurrentWeek(), id: \.self) { date in
                        dayButton(for: date)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Divider()
                .padding(.vertical, 8)

            if viewModel.isLoading {
                ProgressView("Загрузка календаря...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if let outfit = viewModel.scheduledOutfit(for: selectedDate) {
                outfitCard(outfit)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                    Text("На этот день ничего не запланировано")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }

            Spacer()
        }
        .navigationTitle("Календарь")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.fetchCalendar()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker(
                    "Выберите дату",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()

                Button("Готово") {
                    showDatePicker = false
                }
                .padding()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button(action: {
                showDatePicker.toggle()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .imageScale(.medium)

                    Text(selectedDate.formatted(.dateTime.day().month().year()))
                        .font(.headline)
                        .fontWeight(.medium)

                    Image(systemName: "chevron.down.circle")
                        .rotationEffect(.degrees(showDatePicker ? 180 : 0))
                        .foregroundColor(.blue)
                        .imageScale(.medium)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Day Buttons

    private func dayButton(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let hasOutfit = viewModel.scheduledOutfit(for: date) != nil

        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text(dayName(from: date))
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(dayNumber(from: date))
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.clear)
                    )

                // 🔵 Dot if outfit exists
                Circle()
                    .fill(hasOutfit ? Color.blue : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 50)
        }
    }

    // MARK: - Outfit Display

    private func outfitCard(_ entry: ScheduledOutfitResponse) -> some View {
        VStack(spacing: 12) {
            if let imagePath = entry.outfit.imagePath, let url = URL(string: imagePath) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250, maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 250, height: 250)
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Helpers

    private func dayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E"
        return formatter.string(from: date).capitalized
    }

    private func dayNumber(from date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return String(day)
    }

    private func datesInCurrentWeek() -> [Date] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: selectedDate) else {
            return []
        }
        let startOfWeek = weekInterval.start
        return (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }
}


