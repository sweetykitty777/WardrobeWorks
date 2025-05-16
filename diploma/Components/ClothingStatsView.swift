import SwiftUI

struct ClothingStatsView: View {
    @ObservedObject var viewModel: FullStatsViewModel
    @State private var showingFullStats = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                showingFullStats = true
            }) {
                Text("Полная статистика")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)

            Text("Статистика за неделю")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 20)

            HStack(spacing: 10) {
                statBox(title: "Вещи", value: "5")
                statBox(title: "Аутфиты", value: "5")
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showingFullStats) {
         //   FullStatsView(viewModel: viewModel)
        }
        .padding(.vertical, 20)
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

}

