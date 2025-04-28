import SwiftUI

struct UserCalendarView: View {
    @StateObject private var viewModel: UserCalendarViewModel

    init(userId: Int) {
        _viewModel = StateObject(wrappedValue: UserCalendarViewModel(userId: userId))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Загрузка календаря...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Text("Ошибка")
                        .font(.title2)
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if viewModel.scheduledOutfits.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding()

                    Text("Календарь пользователя скоро будет доступен!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                LazyVStack(spacing: 24) {
                    ForEach(viewModel.scheduledOutfits, id: \.id) { entry in
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

                            Text(entry.date.formatted(date: .long, time: .omitted))
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .padding(.top, 4)
                        }
                        .frame(width: 260)
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Запланированные аутфиты")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchCalendar()
        }
    }
    
    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 250, height: 250)
            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.gray)
        }
    }

}
