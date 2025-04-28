import SwiftUI

struct OutfitDetailView: View {
    let outfit: OutfitResponse

    @State private var clothes: [ClothItem] = []
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage?
    @State private var isDeleting = false
    @State private var showDeleteErrorAlert = false

    @Environment(\.presentationMode) private var presentationMode

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: — Главное изображение аутфита без обрезки
                if let imagePath = outfit.imagePath, let url = URL(string: imagePath) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                                .onTapGesture { shareImage(from: imagePath) }
                        case .failure:
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.1))
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 220)
                            .padding(.horizontal)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // MARK: — Состав аутфита
                if !clothes.isEmpty {
                    Text("Состав аутфита")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(clothes, id: \.id) { item in
                            NavigationLink(destination: ClothingDetailView(item: item)) {
                                ClothItemViewNotSelectable(item: item)
                                    .frame(height: 160)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Нет вещей в этом аутфите")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                }

                Spacer(minLength: 20)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear { fetchOutfitClothes() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Поделиться изображением
            ToolbarItem(placement: .navigationBarTrailing) {
                if imageToShare != nil {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if isDeleting {
                    ProgressView()
                } else {
                    Button(role: .destructive, action: deleteOutfit) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("Не удалось удалить аутфит", isPresented: $showDeleteErrorAlert) {
            Button("Ок", role: .cancel) { }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = imageToShare {
                ActivityView(activityItems: [image])
            }
        }
    }

    private func deleteOutfit() {
        isDeleting = true
        guard let url = URL(string:
            "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/outfits/\(outfit.id)?outfitId=\(outfit.id)"
        ) else {
            handleDeleteFailure()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isDeleting = false
                let success = (response as? HTTPURLResponse)?.statusCode.isSuccess ?? false
                if error != nil || !success {
                    handleDeleteFailure()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.resume()
    }

    private func handleDeleteFailure() {
        showDeleteErrorAlert = true
    }

    private func fetchOutfitClothes() {
        guard let url = URL(string:
            "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/outfits/\(outfit.id)/clothes?outfitId=\(outfit.id)"
        ) else {
            print("Невалидный URL для вещей аутфита"); return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    if let raw = String(data: data, encoding: .utf8) {
                        print("RAW clothes:\n\(raw)")
                    }
                    do {
                        clothes = try JSONDecoder().decode([ClothItem].self, from: data)
                        print("Loaded \(clothes.count) items")
                    } catch {
                        print(" Decode clothes error:", error.localizedDescription)
                    }
                } else if let error = error {
                    print("Network error:", error.localizedDescription)
                }
            }
        }.resume()
    }

    private func shareImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageToShare = image
                    showShareSheet = true
                }
            }
        }.resume()
    }
}

private extension Int {
    var isSuccess: Bool { (200..<300).contains(self) }
}

// Для шаринга изображения
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
