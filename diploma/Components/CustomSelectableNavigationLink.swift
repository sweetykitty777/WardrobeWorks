import SwiftUI

struct CustomSelectableNavigationLink<T: NamedItem>: View {
    let title: String
    @Binding var selectedItem: T?
    let items: [T]
    var showColorDot: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            NavigationLink(destination: ContentSelectionView(items: items, selectedItem: $selectedItem)) {
                HStack {
                    if showColorDot, let colorItem = selectedItem as? ClothingColor {
                        Circle()
                            .fill(Color(hex: colorItem.colourcode))
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 4)
                    }

                    Text(selectedItem?.name ?? "Добавить \(title.lowercased())")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
}

struct CustomSelectableRow<T: NamedItem>: View {
    let title: String
    let selectedItem: T?
    var showColorDot: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                if showColorDot, let colorItem = selectedItem as? ClothingColor {
                    Circle()
                        .fill(Color(hex: colorItem.colourcode))
                        .frame(width: 16, height: 16)
                    Spacer().frame(width: 4)
                }

                Text(selectedItem?.name ?? "Добавить \(title.lowercased())")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .medium))

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}
