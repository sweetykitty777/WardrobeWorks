import SwiftUI

struct WardrobePickerView: View {
    @Binding var selectedWardrobe: String
    var wardrobes: [UsersWardrobe]
    var onCreateTap: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.95), Color.blue.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            .ignoresSafeArea(edges: .top)

            HStack(spacing: 12) {
                Spacer()

                Menu {
                    // Показываем только гардеробы с непустым именем
                    ForEach(wardrobes.filter { !$0.name.isEmpty }, id: \.id) { wardrobe in
                        Button(action: {
                            selectedWardrobe = wardrobe.name
                        }) {
                            Text(wardrobe.name)
                        }
                    }

                    Divider()

                    // Кнопка "Создать гардероб"
                    Button(action: {
                        onCreateTap()
                    }) {
                        Label("Создать гардероб", systemImage: "plus")
                    }

                } label: {
                    HStack {
                        Text(selectedWardrobe)
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(width: 240, height: 44)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                Spacer()
            }
            .padding(.top, 12)
        }
    }
}
