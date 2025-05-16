import SwiftUI

struct OutfitSelectionView: View {
    @ObservedObject var viewModel: OutfitViewModel
    @Binding var selectedOutfit: OutfitResponse?

    @State private var wardrobes: [UsersWardrobe] = []
    @State private var selectedWardrobeId: Int?
    @State private var isLoading = false
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        VStack {
            // Меню выбора гардероба
            Menu {
                ForEach(wardrobes, id: \.id) { wardrobe in
                    Button(wardrobe.name) {
                        selectedWardrobeId = wardrobe.id
                        loadOutfits(for: wardrobe.id)
                    }
                }
            } label: {
                HStack {
                    Text(selectedWardrobeName)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal)
            }

            if isLoading {
                ProgressView("Загрузка аутфитов...")
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.outfits) { outfit in
                            HStack {
                                if let imagePath = outfit.imagePath,
                                   let url = URL(string: imagePath) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        default:
                                            Color.gray
                                        }
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.gray)
                                }

                                Text(outfit.name)
                                    .font(.headline)

                                Spacer()

                                if outfit.id == selectedOutfit?.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                            .onTapGesture {
                                selectedOutfit = outfit
                            }
                        }
                    }
                    .padding()
                }
            }

            Spacer()
        }
        .navigationTitle("Выбор аутфита")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchWardrobes()
        }
        .overlay(toastOverlay, alignment: .top)
    }

    private var selectedWardrobeName: String {
        if let id = selectedWardrobeId,
           let wardrobe = wardrobes.first(where: { $0.id == id }) {
            return wardrobe.name
        }
        return "Выбрать гардероб"
    }

    private var toastOverlay: some View {
        Group {
            if showToast {
                Text(toastMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
            }
        }
    }

    private func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    wardrobes = fetched.filter { !$0.isPrivate }
                    if wardrobes.isEmpty {
                        showToast(message: "Нет публичных гардеробов")
                    }
                case .failure(let error):
                    showToast(message: "Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        }
    }

    private func loadOutfits(for wardrobeId: Int) {
        isLoading = true
        viewModel.fetchOutfits(for: wardrobeId)
        isLoading = false
    }

    private func showToast(message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
    }
}
