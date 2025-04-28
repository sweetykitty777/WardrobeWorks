import SwiftUI

struct ScheduleOutfitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ScheduleOutfitViewModel
    let onSuccess: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Выбор гардероба
                Menu {
                    ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                        Button(wardrobe.name) {
                            viewModel.selectWardrobe(wardrobe)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedWardrobeName)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
                .padding(.horizontal)

                Text("Выберите аутфит для \(viewModel.formattedDate)")
                    .font(.subheadline)

                // Аутфиты
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.outfits) { outfit in
                            FullWidthOutfitCard(outfit: outfit)
                                .onTapGesture {
                                    viewModel.selectedOutfit = outfit
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(viewModel.selectedOutfit?.id == outfit.id ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal)
                }

                // Поле ввода события
                VStack(alignment: .leading, spacing: 4) {
                    Text("Событие")
                        .font(.caption)
                        .foregroundColor(.gray)

                    TextField("Введите событие (например, вечеринка)", text: $viewModel.eventNote)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                }
                .padding(.horizontal)

                // Кнопка сохранить или лоадер
                if viewModel.isSubmitting {
                    ProgressView()
                        .padding()
                } else {
                    Button("Сохранить") {
                        viewModel.submit {
                            withAnimation(.easeOut(duration: 0.3)) {
                                dismiss()
                            }
                            onSuccess()
                        }
                    }
                    .disabled(viewModel.selectedOutfit == nil)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.selectedOutfit == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Планировать аутфит")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchWardrobes()
            }
            .overlay(
                toastOverlay,
                alignment: .top
            )
        }
    }

    private var toastOverlay: some View {
        Group {
            if viewModel.showToast {
                Text(viewModel.toastMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(viewModel.toastColor)
                    .cornerRadius(12)
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
