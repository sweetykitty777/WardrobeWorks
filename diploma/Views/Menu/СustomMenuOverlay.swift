import SwiftUI

struct CustomMenuOverlay: View {
    @Binding var showingMenu: Bool
    @Binding var showingAddItemSheet: Bool
    @Binding var showingAddOutfitSheet: Bool
    @Binding var showingAddPostSheet: Bool

    @State private var dragOffset: CGFloat = 0

    // Высота меню
    private let menuHeight = UIScreen.main.bounds.height * 0.4

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                menuButton("Добавить вещь") {
                    withAnimation {
                        showingMenu = false
                        showingAddItemSheet = true
                    }
                }
                menuButton("Создать аутфит") {
                    withAnimation {
                        showingMenu = false
                        showingAddOutfitSheet = true
                    }
                }
                menuButton("Создать пост") {
                    withAnimation {
                        showingMenu = false
                        showingAddPostSheet = true
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(height: menuHeight)
            .frame(maxWidth: .infinity)
            .background(
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .offset(y: showingMenu
                    ? dragOffset
                    : menuHeight + dragOffset
            )
            .gesture(
                DragGesture()
                    .onChanged { g in
                        // тянем вниз
                        if g.translation.height > 0 {
                            dragOffset = g.translation.height
                        }
                    }
                    .onEnded { g in
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3)) {
                            if g.translation.height > menuHeight / 2 {
                                showingMenu = false
                            }
                            dragOffset = 0
                        }
                    }
            )
            // Плавная анимация при смене showingMenu
            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3), value: showingMenu)
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.all)
        .zIndex(1)
    }

    private func menuButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .padding(.horizontal)
    }
}

