import Foundation

class FullStatsViewModel: ObservableObject {
    @Published var wardrobes: [UsersWardrobe] = []
    @Published var selectedWardrobe: UsersWardrobe? {
        didSet {
            if let id = selectedWardrobe?.id {
                fetchStats(for: id)
                fetchTimeBasedStats(for: id)
            }
        }
    }

    @Published var allStats: AllStatisticsResponse?

    @Published var createdStats7Days: CreatedStatisticsResponse?
    @Published var createdStats30Days: CreatedStatisticsResponse?
    @Published var createdStats90Days: CreatedStatisticsResponse?
    @Published var createdStats365Days: CreatedStatisticsResponse?

    @Published var plannedStats7Days: PlannedStatisticsResponse?
    @Published var plannedStats30Days: PlannedStatisticsResponse?
    @Published var plannedStats90Days: PlannedStatisticsResponse?
    @Published var plannedStats365Days: PlannedStatisticsResponse?

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let wardrobeService = WardrobeViewModel()

    init() {
        loadWardrobes()
    }

    func loadWardrobes() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    self.wardrobes = wardrobes
                    self.selectedWardrobe = wardrobes.first
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchStats(for wardrobeId: Int) {
        isLoading = true
        errorMessage = nil

        WardrobeService.shared.fetchAllStatistics(wardrobeId: wardrobeId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stats):
                    self?.allStats = stats
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchTimeBasedStats(for wardrobeId: Int) {
        let now = Date()
        let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        let last90Days = Calendar.current.date(byAdding: .day, value: -90, to: now)!
        let last365Days = Calendar.current.date(byAdding: .day, value: -365, to: now)!

        // 🔹 Created
        WardrobeService.shared.fetchCreatedStatistics(wardrobeId: wardrobeId, startDate: last7Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.createdStats7Days = stats
                }
            }
        }

        WardrobeService.shared.fetchCreatedStatistics(wardrobeId: wardrobeId, startDate: last30Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.createdStats30Days = stats
                }
            }
        }

        WardrobeService.shared.fetchCreatedStatistics(wardrobeId: wardrobeId, startDate: last90Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.createdStats90Days = stats
                }
            }
        }

        WardrobeService.shared.fetchCreatedStatistics(wardrobeId: wardrobeId, startDate: last365Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.createdStats365Days = stats
                }
            }
        }

        // 🔹 Planned
        WardrobeService.shared.fetchPlannedStatistics(startDate: last7Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.plannedStats7Days = stats
                }
            }
        }

        WardrobeService.shared.fetchPlannedStatistics(startDate: last30Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.plannedStats30Days = stats
                }
            }
        }

        WardrobeService.shared.fetchPlannedStatistics(startDate: last90Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.plannedStats90Days = stats
                }
            }
        }

        WardrobeService.shared.fetchPlannedStatistics(startDate: last365Days, endDate: now) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let stats) = result {
                    self?.plannedStats365Days = stats
                }
            }
        }
    }
    
    func refreshPlannedLast7Days() {
      let now = Date()
      let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
      WardrobeService.shared.fetchPlannedStatistics(
        startDate: sevenDaysAgo,
        endDate: now
      ) { [weak self] result in
        DispatchQueue.main.async {
          switch result {
          case .success(let stats):
            self?.plannedStats7Days = stats
          case .failure(let error):
            print("Ошибка global planned stats: \(error)")
          }
        }
      }
    }

    // MARK: - Convenience accessors

    func createdStats(for period: StatPeriod) -> CreatedStatisticsResponse? {
        switch period {
        case .sevenDays: return createdStats7Days
        case .thirtyDays: return createdStats30Days
        case .ninetyDays: return createdStats90Days
        case .year: return createdStats365Days
        }
    }

    func plannedStats(for period: StatPeriod) -> PlannedStatisticsResponse? {
        switch period {
        case .sevenDays: return plannedStats7Days
        case .thirtyDays: return plannedStats30Days
        case .ninetyDays: return plannedStats90Days
        case .year: return plannedStats365Days
        }
    }
}
