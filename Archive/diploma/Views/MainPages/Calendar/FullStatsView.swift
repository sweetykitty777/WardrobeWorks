//
//  FullStatsView.swift
//  diploma
//
//  Created by Olga on 01.02.2025.
//

import Foundation
import SwiftUI

struct FullStatsView: View {
    @ObservedObject var viewModel: ClothingStatsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Полная статистика")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)

                statsSection(title: "Общая информация", stats: [
                    ("Всего вещей", "\(viewModel.totalItems)"),
                    ("Аутфитов за неделю", "\(viewModel.weeklyUsage)"),
                    ("Популярный предмет", viewModel.mostPopularItem)
                ])

                statsSection(title: "Топ 5 вещей", stats: viewModel.topFiveItems())

                statsSection(title: "Статистика по сезонам", stats: viewModel.seasonStats())

                statsSection(title: "Самые редкие вещи", stats: viewModel.leastUsedItems())

                Spacer()
            }
            .padding()
        }
    }

    private func statsSection(title: String, stats: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.top, 10)

            ForEach(stats, id: \.0) { stat in
                HStack {
                    Text(stat.0)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(stat.1)
                        .bold()
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
