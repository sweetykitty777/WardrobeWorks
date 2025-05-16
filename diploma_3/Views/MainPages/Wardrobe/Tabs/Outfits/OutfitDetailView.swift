import SwiftUI

import SwiftUI

struct OutfitDetailView: View {
    let outfit: Outfit
    @State private var clothingItems: [ClothingItem] = MockData.clothingItems
    @State private var scheduledOutfits: [ScheduledOutfit] = []
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage?

    var scheduledDates: [Date] {
        scheduledOutfits
            .filter { $0.outfit.id == outfit.id }
            .map { $0.date }
            .sorted()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Карточка аутфита
                if let imageName = outfit.imageName,
                   let image = UIImage(named: imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .padding(.horizontal)
                        .padding(.top)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .onAppear {
                            imageToShare = image
                        }
                }

                // Заголовок
                Text("Состав аутфита")
                    .font(.headline)
                    .padding(.horizontal)

                // Вещи в аутфите
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(outfit.outfitItems, id: \.id) { item in
                            if let index = clothingItems.firstIndex(where: { $0.image_str == item.imageName }) {
                                NavigationLink(destination: ClothingDetailView(item: $clothingItems[index], clothingItems: $clothingItems)) {
                                    if let imageName = clothingItems[index].image_str,
                                       let image = UIImage(named: imageName) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 90, height: 90)
                                            .padding(10)
                                            .background(Color.white)
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Даты планирования
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Запланирован на:")
                            .font(.headline)
                        Spacer()
                        NavigationLink(destination: WeeklyCalendarView()) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)

                    if !scheduledDates.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(scheduledDates, id: \.self) { date in
                                    Text(shortDate(date))
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                        .shadow(radius: 1)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)

                Spacer(minLength: 20)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            scheduledOutfits = MockData.scheduledOutfits
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let _ = imageToShare {
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = imageToShare {
                ActivityView(activityItems: [image])
            }
        }
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

