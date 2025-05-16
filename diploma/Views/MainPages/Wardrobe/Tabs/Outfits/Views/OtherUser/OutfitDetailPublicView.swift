import SwiftUI

struct OutfitDetailPublicView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: OutfitDetailViewModel
    @StateObject private var copyViewModel = ClothingDetailPublicViewModel()

    @State private var showCopiedToast = false

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
                clothesSection
                copyAllButton

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
        }
        .onAppear {
            viewModel.loadInitialData()
            copyViewModel.fetchWardrobes()
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let image = viewModel.imageToShare {
                ActivityView(activityItems: [image])
            }
        }
        .toast(isPresented: $showCopiedToast, message: "Вещь успешно скопирована ✅")
    }


    private var clothesSection: some View {
        Group {
            if !viewModel.clothes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Состав аутфита")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.clothes) { item in
                            VStack(spacing: 8) {
                                NavigationLink(value: PublicClothRoute(item: item)) {
                                    ClothItemViewNotSelectable(item: item)
                                        .frame(height: 160)
                                }

                                // Кнопка копирования конкретной вещи
                                Menu {
                                    ForEach(copyViewModel.wardrobes, id: \.id) { wardrobe in
                                        Button {
                                            copyViewModel.copyItem(clothId: item.id, to: wardrobe.id) {
                                                showCopiedToast = true
                                            }
                                        } label: {
                                            Text("В \(wardrobe.name)")
                                        }
                                    }
                                } label: {
                                    Text("Скопировать")
                                        .font(.caption)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("Нет вещей в этом аутфите")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    private var copyAllButton: some View {
        Group {
            if !viewModel.clothes.isEmpty {
                AnyView(
                    Menu {
                        ForEach(copyViewModel.wardrobes, id: \.id) { wardrobe in
                            Button {
                                for item in viewModel.clothes {
                                    copyViewModel.copyItem(clothId: item.id, to: wardrobe.id) {
                                        showCopiedToast = true
                                    }
                                }
                            } label: {
                                Text("В \(wardrobe.name)")
                            }
                        }
                    } label: {
                        Text("Скопировать все вещи")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                )
            } else {
                AnyView(EmptyView())
            }
        }
    }

}
