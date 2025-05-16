import SwiftUI

struct ScheduleOutfitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ScheduleOutfitViewModel
    let onSuccess: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        wardrobePicker
                        dateInfo
                        outfitScroll
                        eventInput
                        saveButton
                    }
                    .padding()
                }

                if viewModel.showToast {
                    VStack {
                        toastOverlay
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: viewModel.showToast)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Планировать аутфит")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchWardrobes()
            }
        }
    }

    private var wardrobePicker: some View {
        Menu {
            ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                Button(wardrobe.name) {
                    viewModel.selectWardrobe(wardrobe)
                }
            }
        } label: {
            HStack {
                Text(viewModel.selectedWardrobeName)
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    private var dateInfo: some View {
        Text("Выберите аутфит для \(viewModel.formattedDate)")
            .font(.subheadline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private var outfitScroll: some View {
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
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var eventInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Событие")
                .font(.caption)
                .foregroundColor(.gray)

            TextField("Введите событие (например, вечеринка)", text: Binding(
                get: { viewModel.eventNote },
                set: { newValue in
                    if newValue.count <= InputLimits.eventNameMaxLength {
                        viewModel.eventNote = newValue
                    } else {
                        viewModel.eventNote = String(newValue.prefix(InputLimits.eventNameMaxLength))
                    }
                })
            )
            .padding()
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

            HStack {
                Spacer()
                Text("\(viewModel.eventNote.count)/\(InputLimits.eventNameMaxLength)")
                    .font(.caption)
                    .foregroundColor(viewModel.eventNote.count >= InputLimits.eventNameMaxLength ? .red : .gray)
            }
        }
    }

    private var saveButton: some View {
        Group {
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
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(viewModel.selectedOutfit == nil ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.top, 8)
    }

    private var toastOverlay: some View {
        Text(viewModel.toastMessage)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .background(viewModel.toastColor)
            .cornerRadius(12)
            .padding(.top, 20)
    }
}
