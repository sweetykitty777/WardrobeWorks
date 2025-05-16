import SwiftUI

struct LookbookListItemView: View {
    var title: String
    var subtitle: String
    var onEdit: () -> Void
    var isEditing: Bool
    @Binding var textFieldText: String
    var onCommit: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Название лукбука", text: $textFieldText, onCommit: onCommit)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if isEditing {
                Button(action: onCommit) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            } else {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
