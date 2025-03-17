import SwiftUI

struct CustomMenuOverlay: View {
    @Binding var showingMenu: Bool
    @Binding var showingAddItemSheet: Bool
    @Binding var showingAddOutfitSheet: Bool
    @Binding var showingAddPostSheet: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            
            if showingMenu {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showingMenu = false
                        }
                    }
            }


            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Button(action: {
                    withAnimation(.spring()) {
                        showingMenu = false
                        showingAddItemSheet = true
                    }
                }) {
                    HStack {
                        Text("Добавить вещь")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
                .padding(.horizontal, 20)


                Button(action: {
                    withAnimation(.spring()) {
                        showingMenu = false
                        showingAddOutfitSheet = true
                    }
                }) {
                    HStack {
                        Text("Создать аутфит")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
                .padding(.horizontal, 20)

                Button(action: {
                    withAnimation(.spring()) {
                        showingMenu = false
                        showingAddPostSheet = true
                    }
                }) {
                    HStack {
                        Text("Создать пост")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .offset(y: showingMenu ? 0 : 300) 
            .transition(.move(edge: .bottom))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
