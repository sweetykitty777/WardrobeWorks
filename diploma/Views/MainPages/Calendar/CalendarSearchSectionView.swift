import SwiftUI

struct CalendarSearchSectionView: View {
    @ObservedObject var inspirationViewModel: InspirationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Поиск календарей других пользователей")
                .font(.headline)
                .padding(.horizontal)

            TextField("Введите ник пользователя...", text: $inspirationViewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .submitLabel(.search)
                .onSubmit {
                    inspirationViewModel.searchUsers()
                }

            if !inspirationViewModel.searchResults.isEmpty {
                ForEach(inspirationViewModel.searchResults) { user in
                    NavigationLink(
                        destination: UserCalendarView(userId: user.id)
                    ) {
                        HStack(spacing: 12) {
                            if let avatar = user.avatar {
                                RemoteImageView(
                                    urlString: avatar,
                                    cornerRadius: 20,
                                    width: 40,
                                    height: 40
                                )
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                            VStack(alignment: .leading) {
                                Text("@\(user.username)")
                                    .fontWeight(.semibold)
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
