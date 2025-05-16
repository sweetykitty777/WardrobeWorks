import SwiftUI

struct FullStatsView: View {
    @ObservedObject var viewModel: FullStatsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: StatPeriod = .sevenDays

    var body: some View {
          ScrollView {
              VStack(alignment: .leading, spacing: 24) {
                  Text("Статистика")
                      .font(.title2.bold())
                      .padding(.top, 8)

                  VStack(alignment: .leading, spacing: 12) {
                      Text("Статистика по гардеробу")
                          .font(.headline)
                      wardrobePicker
                  }

                  if viewModel.isLoading {
                      HStack {
                          Spacer()
                          ProgressView("Загрузка...")
                          Spacer()
                      }
                  } else if let stats = viewModel.allStats {
                      statsCards(stats)

                      VStack(alignment: .leading, spacing: 12) {
                          Text("Статистика по времени")
                              .font(.headline)

                          periodButtons

                          let created = viewModel.createdStats(for: selectedPeriod)
                          let planned = viewModel.plannedStats(for: selectedPeriod)

                          if created == nil && planned == nil {
                              Text("Данных пока нет")
                                  .foregroundColor(.gray)
                                  .padding(.top, 4)
                          } else {
                              statPeriodGroup(
                                  title: selectedPeriod.displayName,
                                  created: created,
                                  planned: planned
                              )
                          }
                      }
                  } else if let error = viewModel.errorMessage {
                      Text("Ошибка: \(error)")
                          .foregroundColor(.red)
                  } else {
                      Text("Данных пока нет")
                          .foregroundColor(.gray)
                  }

                  Spacer()
              }
              .padding()
          }
          .background(Color.white)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarBackButtonHidden(true)
          .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                  Button(action: {
                      dismiss()
                  }) {
                      Image(systemName: "chevron.backward")
                          .foregroundColor(.blue)
                  }
              }
          }
          .onAppear {
              viewModel.loadWardrobes()
          }
      }
    // MARK: - UI Components

    var wardrobePicker: some View {
        Menu {
            ForEach(viewModel.wardrobes, id: \.id) { wardrobe in
                Button(action: {
                    viewModel.selectedWardrobe = wardrobe
                }) {
                    Text(wardrobe.name)
                }
            }
        } label: {
            HStack {
                Text(viewModel.selectedWardrobe?.name ?? "Выбрать гардероб")
                    .foregroundColor(.black)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    var periodButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(StatPeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                    }) {
                        Text(period.displayName)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .foregroundColor(selectedPeriod == period ? .blue : .gray)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }

    func statsCards(_ stats: AllStatisticsResponse) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                statCard(title: "Образы", value: stats.allOutfitsNumber, systemImage: "photo.on.rectangle")
                statCard(title: "Одежда", value: stats.allClothesNumber, systemImage: "tshirt")
            }

            HStack(spacing: 16) {
                if let brand = stats.favouriteBrand {
                    statCard(title: "Любимый бренд", value: brand.name)
                } else {
                    statCard(title: "Любимый бренд", value: "-")
                }

                if let colour = stats.favouriteColour {
                    statCard(title: "Любимый цвет", value: colour.name, color: Color(hex: colour.colourcode))
                } else {
                    statCard(title: "Любимый цвет", value: "-")
                }
            }
        }
    }


    func statPeriodGroup(
        title: String,
        created: CreatedStatisticsResponse?,
        planned: PlannedStatisticsResponse?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let created = created {
                Text("Создано").font(.subheadline).foregroundColor(.gray)
                HStack(spacing: 16) {
                    statCard(title: "Образы", value: created.outfitsNumber, systemImage: "photo.on.rectangle")
                    statCard(title: "Одежда", value: created.clothesNumber, systemImage: "tshirt")
                }
            }

            if let planned = planned {
                Text("Запланировано").font(.subheadline).foregroundColor(.gray)
                HStack(spacing: 16) {
                    statCard(title: "Образы", value: planned.outfitsNumber, systemImage: "photo.on.rectangle")
                    statCard(title: "Одежда", value: planned.clothesNumber, systemImage: "tshirt")
                }
            }
        }
    }

    func statCard(title: String, value: Any, systemImage: String? = nil, color: Color? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if let color = color {
                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 16, height: 16)
                    Text("\(value)")
                        .font(.headline)
                }
            } else {
                Text("\(value)")
                    .font(.title2.bold())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - StatPeriod Enum

enum StatPeriod: String, CaseIterable, Hashable {
    case sevenDays, thirtyDays, ninetyDays, year

    var displayName: String {
        switch self {
        case .sevenDays: return "7 дней"
        case .thirtyDays: return "30 дней"
        case .ninetyDays: return "90 дней"
        case .year: return "365 дней"
        }
    }
}

