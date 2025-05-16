import Foundation

extension WardrobeService {

    func fetchCreatedStatistics(
        wardrobeId: Int,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<CreatedStatisticsResponse, Error>) -> Void
    ) {
        let payload = StatisticsRequest(startDate: startDate, endDate: endDate)
        let encoder = JSONEncoder.iso8601withMilliseconds

        guard let body = try? encoder.encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.request(
            path: "/wardrobe-service/statistics/\(wardrobeId)/created",
            method: "POST",
            body: body,
            decodeTo: CreatedStatisticsResponse.self,
            dateDecoding: true,
            completion: completion
        )
    }

    func fetchPlannedStatistics(
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<PlannedStatisticsResponse, Error>) -> Void
    ) {
        let payload = StatisticsRequest(startDate: startDate, endDate: endDate)
        let encoder = JSONEncoder.iso8601withMilliseconds

        guard let body = try? encoder.encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.request(
            path: "/wardrobe-service/statistics/planned",
            method: "POST",
            body: body,
            decodeTo: PlannedStatisticsResponse.self,
            dateDecoding: true,
            completion: completion
        )
    }

    func fetchAllStatistics(
        wardrobeId: Int,
        completion: @escaping (Result<AllStatisticsResponse, Error>) -> Void
    ) {
        api.request(
            path: "/wardrobe-service/statistics/\(wardrobeId)/all",
            method: "POST",
            decodeTo: AllStatisticsResponse.self,
            dateDecoding: true,
            completion: completion
        )
    }
}

extension JSONEncoder {
    static var iso8601withMilliseconds: JSONEncoder {
        let encoder = JSONEncoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            let dateString = formatter.string(from: date)
            var container = encoder.singleValueContainer()
            try container.encode(dateString)
        }
        return encoder
    }
}

