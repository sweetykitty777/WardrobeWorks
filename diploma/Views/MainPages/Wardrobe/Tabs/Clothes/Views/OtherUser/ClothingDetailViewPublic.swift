import Foundation
import SwiftUI

struct ClothingDetailViewPublic: View {
    let item: ClothItem
    @StateObject private var viewModel = ClothingDetailPublicViewModel()

    @State private var showCopiedToast = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                ClothingDetailContentView(item: item)

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
