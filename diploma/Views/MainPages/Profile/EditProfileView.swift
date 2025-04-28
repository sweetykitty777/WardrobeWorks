import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) var dismiss

    @State private var bio: String = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                // Аватарка
                VStack(spacing: 8) {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(avatarEditButton, alignment: .bottomTrailing)
                    } else if let url = URL(string: viewModel.user.avatar ?? "") {
                        RemoteImageView(urlString: url.absoluteString, cornerRadius: 50, width: 100, height: 100)
                            .overlay(avatarEditButton, alignment: .bottomTrailing)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            )
                            .overlay(avatarEditButton, alignment: .bottomTrailing)
                    }
                }
                .padding(.top, 20)

                Form {
                    Section(header: Text("О себе")) {
                        TextField("О себе", text: $bio)
                    }

                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Редактировать")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Сохранение..." : "Сохранить") {
                        saveProfile()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                bio = viewModel.user.bio ?? ""
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
        }
    }

    private var avatarEditButton: some View {
        Button(action: {
            viewModel.showingImagePicker = true
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.blue)
                .background(Color.white)
                .clipShape(Circle())
                .font(.title2)
                .offset(x: 4, y: 4)
        }
    }

    private func saveProfile() {
        isSaving = true
        showError = false

        viewModel.uploadAvatarIfNeeded { avatarResult in
            switch avatarResult {
            case .success(let imageUrl):
                if let url = imageUrl {
                    viewModel.updateAvatar(url) { _ in }
                }

                viewModel.updateBio(bio) { result in
                    DispatchQueue.main.async {
                        isSaving = false
                        switch result {
                        case .success:
                            dismiss()
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
