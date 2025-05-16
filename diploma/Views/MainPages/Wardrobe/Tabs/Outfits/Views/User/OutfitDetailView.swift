import SwiftUI

struct OutfitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: OutfitDetailViewModel

    init(outfit: OutfitResponse) {
        _viewModel = StateObject(wrappedValue: OutfitDetailViewModel(outfit: outfit))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let imagePath = viewModel.outfit.imagePath, !imagePath.isEmpty {
                    CachedImageView(
                        urlString: imagePath,
                        width: nil,
                        height: 360
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.shareImage(from: imagePath)
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .foregroundColor(.gray)
                }

                dateSection
                clothesSection

                Button("Редактировать") {
                    viewModel.showEditView = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                Button("Удалить аутфит") {
                    viewModel.deleteOutfit { success in
                        if success { dismiss() }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if let imagePath = viewModel.outfit.imagePath {
                    Button(action: {
                        viewModel.shareImage(from: imagePath)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadInitialData()
        }
        .alert("Не удалось удалить аутфит", isPresented: $viewModel.showDeleteErrorAlert) {
            Button("Ок", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let image = viewModel.imageToShare {
                ActivityView(activityItems: [image, viewModel.textToShare ?? "Сделано в WardrobeWorks"])
            }
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            NavigationStack {
                VStack {
                    DatePicker("Выберите дату", selection: $viewModel.selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding()

                    Button("Запланировать", action: viewModel.scheduleOutfitDate)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding()
                }
                .navigationTitle("Новая дата")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") {
                            viewModel.showDatePicker = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showEditView) {
            EditOutfitView(outfitId: viewModel.outfit.id)
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Запланировано на:")
                    .font(.headline)
                Spacer()
                Button {
                    viewModel.showDatePicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }

            let futureDates = viewModel.scheduledDates.filter {
                Calendar.current.isDateInToday($0) || $0 > Date()
            }

            if futureDates.isEmpty {
                Text("Даты отсутствуют")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(futureDates, id: \.self) { date in
                            Text(date.formatted(date: .long, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue)
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteCalendarEntry(for: date)
                                    } label: {
                                        Label("Удалить дату", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var clothesSection: some View {
        Group {
            if !viewModel.clothes.isEmpty {
                Text("Состав аутфита")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.clothes) { item in
                        NavigationLink(value: item) {
                            ClothItemViewNotSelectable(item: item)
                                .frame(height: 160)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Нет вещей в этом аутфите")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}
