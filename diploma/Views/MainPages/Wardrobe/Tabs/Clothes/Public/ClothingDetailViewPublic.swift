import Foundation
import SwiftUI

struct ClothingDetailViewPublic: View {
    let item: ClothItem
    @StateObject private var viewModel = ClothingDetailPublicViewModel()

    @State private var showCopiedToast = false
    @State private var showWardrobeMenu = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Фото
                RemoteImageView(urlString: item.imagePath)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 4)
                    .padding(.horizontal)

                // Информация о вещи
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(title: "Бренд", value: item.brandName ?? "—")
                    InfoRow(title: "Цвет", value: item.colourName ?? "—")
                    InfoRow(title: "Сезон", value: item.seasonName ?? "—")
                    InfoRow(title: "Категория", value: item.typeName ?? "—")
                    InfoRow(title: "Цена", value: "\(item.price ?? 0) ₽")
                    InfoRow(title: "Описание", value: item.description ?? "—")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)

                // Кнопка копирования
                Menu {
                    ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                        Button(action: {
                            viewModel.copyItem(clothId: item.id, to: wardrobe.id) {
                                showCopiedToast = true
                            }
                        }) {
                            Text(wardrobe.name)
                        }
                    }
                } label: {
                    Text("Скопировать вещь")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Вещь")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toast(isPresented: $showCopiedToast, message: "Вещь успешно скопирована ✅")
        .onAppear {
            viewModel.fetchWardrobes()
        }
    }
}



// Очень простая вспомогательная вью для тоста (можно заменить на любую свою красивую)
extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                VStack {
                    Spacer()
                    Text(message)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: isPresented.wrappedValue)
                }
            }
        }
    }
}
