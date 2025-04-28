import SwiftUI

struct WardrobePickerSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var wardrobeViewModel = WardrobeViewModel()

    let onSelect: (UsersWardrobe) -> Void

    var body: some View {
        NavigationView {
            List(wardrobeViewModel.wardrobes, id: \.id) { wardrobe in
                Button(action: {
                    onSelect(wardrobe)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(wardrobe.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Выберите гардероб")
            .onAppear {
                wardrobeViewModel.fetchWardrobes()
            }
        }
    }
}
