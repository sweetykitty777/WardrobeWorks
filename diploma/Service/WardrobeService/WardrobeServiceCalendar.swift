//
//  WardrobeServiceCalendar.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

extension WardrobeService {

    // MARK: - Public API

    func fetchUserCalendars(userId: Int, completion: @escaping (Result<[UserCalendar], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/calendar/\(userId)/all",
            method: "GET",
            decodeTo: [UserCalendar].self,
            completion: completion
        )
    }

    func fetchCalendars(completion: @escaping (Result<[UserCalendar], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/calendar/all",
            method: "GET",
            decodeTo: [UserCalendar].self,
            completion: completion
        )
    }

    func fetchCalendarEntries(calendarId: Int, completion: @escaping (Result<[ScheduledOutfitResponse], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/calendar/\(calendarId)/entry/all?calendarId=\(calendarId)",
            method: "GET",
            decodeTo: [ScheduledOutfitResponse].self,
            dateDecoding: true,
            completion: completion
        )
    }

    func scheduleOutfit(outfitId: Int, date: Date, note: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        fetchCalendars { result in
            switch result {
            case .success(let calendars):
                guard let calendar = calendars.first else {
                    return completion(.failure(NSError(domain: "No calendar", code: 404)))
                }
                self.createCalendarEntry(calendarId: calendar.id, outfitId: outfitId, date: date, note: note, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteScheduledOutfit(entryId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/calendar/entry/\(entryId)?entryId=\(entryId)",
            method: "DELETE",
            completion: completion
        )
    }

    func fetchScheduledDates(for outfitId: Int, completion: @escaping ([Date]) -> Void) {
        fetchCalendars { result in
            switch result {
            case .success(let calendars):
                guard let calendar = calendars.first else { return completion([]) }
                self.fetchCalendarEntries(calendarId: calendar.id) { result in
                    switch result {
                    case .success(let entries):
                        let dates = entries
                            .filter { $0.outfit.id == outfitId }
                            .map { $0.date }
                        completion(dates)
                    case .failure:
                        completion([])
                    }
                }
            case .failure:
                completion([])
            }
        }
    }

    func deleteCalendarEntry(for outfitId: Int, date: Date, completion: @escaping (Bool) -> Void) {
        fetchCalendars { result in
            switch result {
            case .success(let calendars):
                guard let calendar = calendars.first else { return completion(false) }
                self.fetchCalendarEntries(calendarId: calendar.id) { result in
                    switch result {
                    case .success(let entries):
                        if let entry = entries.first(where: {
                            $0.outfit.id == outfitId && Calendar.current.isDate($0.date, inSameDayAs: date)
                        }) {
                            self.deleteScheduledOutfit(entryId: entry.id) {
                                completion((try? $0.get()) != nil)
                            }
                        } else {
                            completion(false)
                        }
                    case .failure:
                        completion(false)
                    }
                }
            case .failure:
                completion(false)
            }
        }
    }

    // MARK: - Private Helpers

    private func createCalendarEntry(calendarId: Int, outfitId: Int, date: Date, note: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body: [String: Any] = [
            "outfitId": outfitId,
            "date": DateFormatter.short.string(from: date),
            "eventNote": note
        ]

        guard let encoded = try? JSONSerialization.data(withJSONObject: body) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/calendar/\(calendarId)/entry/create?calendarId=\(calendarId)",
            method: "POST",
            body: encoded,
            completion: completion
        )
    }
}
