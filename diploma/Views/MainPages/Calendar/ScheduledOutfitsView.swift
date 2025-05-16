import SwiftUI

struct ScheduledOutfitView: View {
    @ObservedObject var viewModel: ScheduledOutfitViewModel
    @Binding var showingAddOutfitSheet: Bool
    @State private var showingDeleteConfirmation = false

    var body: some View {
        if let scheduled = viewModel.scheduledOutfit {
            VStack(spacing: 16) {
                FullWidthOutfitCard(outfit: scheduled.outfit)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .center)


                if let note = scheduled.eventNote, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.footnote)
                        Text("Удалить запись")
                            .font(.footnote)
                    }
                    .foregroundColor(.gray)
                }
                .padding(.top, 8)
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(
                        title: Text("Удалить запись?"),
                        message: Text("Вы уверены, что хотите удалить эту запись из календаря?"),
                        primaryButton: .destructive(Text("Удалить")) {
                            viewModel.deleteScheduled()
                        },
                        secondaryButton: .cancel(Text("Отмена"))
                    )
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)
            .overlay(
                toastOverlay,
                alignment: .top
            )
        } else {
            AddOutfitButton(showingAddOutfitSheet: $showingAddOutfitSheet)
                .frame(maxWidth: .infinity)
        }
    }


    private var toastOverlay: some View {
        Group {
            if viewModel.showToast {
                Text(viewModel.toastMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(viewModel.toastColor)
                    .cornerRadius(12)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { viewModel.showToast = false }
                        }
                    }
            }
        }
    }
}
