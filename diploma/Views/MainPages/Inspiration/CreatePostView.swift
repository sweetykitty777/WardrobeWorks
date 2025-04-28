import SwiftUI

struct CreatePostView: View {
    @Binding var posts: [Post]
    @ObservedObject var outfitViewModel: OutfitViewModel
    @StateObject private var viewModel = CreatePostViewModel()

    // Доля экрана, которую займёт картинка
    private let imageWidthRatio: CGFloat = 0.7

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // MARK: — Выбор гардероба
                Menu {
                    ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                        Button(wardrobe.name) {
                            viewModel.selectedWardrobeId = wardrobe.id
                            loadOutfits(for: wardrobe.id)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedWardrobeName)
                            .foregroundColor(viewModel.selectedWardrobeId == nil ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)

                // MARK: — Горизонтальный скролл аутфитов
                if outfitViewModel.outfits.isEmpty {
                    Text("Выберите гардероб")
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
                } else {
                    let screenW = UIScreen.main.bounds.width
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(outfitViewModel.outfits) { outfit in
                                AsyncImage(url: URL(string: outfit.imagePath ?? "")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit() // сохраняет пропорции
                                            .frame(width: screenW * imageWidthRatio)
                                    default:
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(width: screenW * imageWidthRatio,
                                                       height: screenW * imageWidthRatio)
                                            Image(systemName: "photo")
                                                .font(.system(size: 36))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            viewModel.selectedOutfit?.id == outfit.id
                                                ? Color.blue
                                                : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .onTapGesture {
                                    viewModel.selectedOutfit = outfit
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // MARK: — Описание поста
                TextField("Описание поста", text: $viewModel.description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // MARK: — Кнопка публикации
                Button("Опубликовать пост") {
                    viewModel.createPost()
                }
                .disabled(viewModel.selectedOutfit == nil || viewModel.description.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background((viewModel.selectedOutfit == nil || viewModel.description.isEmpty) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Создать пост")
            .onAppear {
                viewModel.fetchWardrobes()
            }
            .overlay(toastOverlay, alignment: .top)
        }
    }

    // MARK: — Helpers

    private var selectedWardrobeName: String {
        if let id = viewModel.selectedWardrobeId,
           let wardrobe = viewModel.wardrobes.first(where: { $0.id == id }) {
            return wardrobe.name
        }
        return "Выбрать гардероб"
    }

    private func loadOutfits(for wardrobeId: Int) {
        viewModel.isLoading = true
        outfitViewModel.fetchOutfits(for: wardrobeId)
        // через полсекунды проверяем, загрузились ли аутфиты
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.isLoading = false
            if outfitViewModel.outfits.isEmpty {
                viewModel.showToast(message: "Не удалось загрузить аутфиты")
            }
        }
    }

    private var toastOverlay: some View {
        Group {
            if viewModel.showToast {
                Text(viewModel.toastMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
