import SwiftUI

struct ClothingStatsView: View {
    @ObservedObject var viewModel: ClothingStatsViewModel
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
                statBox(title: "Всего вещей", value: "\(viewModel.totalItems)")
                statBox(title: "Аутфитов", value: "\(viewModel.weeklyUsage)")
                statBox(title: "Популярное", value: viewModel.mostPopularItem)
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .sheet(isPresented: $showingFullStats) {
            FullStatsView(viewModel: viewModel)
        }
    }

    /// **Квадратики статистики**
    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.body)
                .bold()
                .foregroundColor(.black)
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

