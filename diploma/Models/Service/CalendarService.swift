import Foundation

class CalendarService {
    static let shared = CalendarService()

    private init() {}
    
    func fetchUserCalendars(userId: Int, completion: @escaping (Result<[UserCalendar], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/calendar/\(userId)/all") else {
            print("Невалидный URL для получения календарей пользователя")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("Запрос получения календарей пользователя: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка сети при получении календарей: \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Код ответа: \(httpResponse.statusCode)")
                }

                guard let data = data else {
                    print("Нет данных в ответе сервера")
                    completion(.failure(NSError(domain: "No data", code: 500)))
                    return
                }

                print("Ответ сервера:\n\(String(data: data, encoding: .utf8) ?? "Невозможно декодировать")")

                do {
                    let calendars = try JSONDecoder().decode([UserCalendar].self, from: data)
                    print("Загружено календарей: \(calendars.count)")
                    completion(.success(calendars))
                } catch {
                    print("Ошибка декодирования календарей: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    
    func fetchCalendarEntries(calendarId: Int, completion: @escaping (Result<[ScheduledOutfitResponse], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/calendar/\(calendarId)/entry/all?calendarId=\(calendarId)") else {
            print("Невалидный URL для записей календаря")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("Запрос записей календаря: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка сети при получении записей: \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Код ответа: \(httpResponse.statusCode)")
                }

                guard let data = data else {
                    print("Нет данных в ответе")
                    completion(.failure(NSError(domain: "No data", code: 500)))
                    return
                }

                print("Ответ сервера:\n\(String(data: data, encoding: .utf8) ?? "Невозможно декодировать")")

                do {
                    let decoder = JSONDecoder()
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                    let shortFormatter = DateFormatter()
                    shortFormatter.locale = Locale(identifier: "en_US_POSIX")
                    shortFormatter.dateFormat = "yyyy-MM-dd"

                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        if let isoDate = isoFormatter.date(from: dateString) {
                            return isoDate
                        }
                        if let shortDate = shortFormatter.date(from: dateString) {
                            return shortDate
                        }
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Невалидная дата: \(dateString)")
                    }

                    let entries = try decoder.decode([ScheduledOutfitResponse].self, from: data)
                    print("Загружено записей: \(entries.count)")
                    completion(.success(entries))
                } catch {
                    print("Ошибка декодирования записей: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: — Получить все календари
    func fetchCalendars(completion: @escaping (Result<[UserCalendar], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/calendar/all") else {
            print("Невалидный URL для календарей")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("Отправляем запрос на загрузку календарей: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка загрузки календарей: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("Нет данных при загрузке календарей")
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }

            let raw = String(data: data, encoding: .utf8) ?? "Невозможно декодировать ответ в строку"
            print("Ответ на загрузку календарей:\n\(raw)")

            do {
                let calendars = try JSONDecoder().decode([UserCalendar].self, from: data)
                print("Календари успешно загружены: \(calendars.count) штук")
                completion(.success(calendars))
            } catch {
                print("Ошибка парсинга календарей: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: — Создать запись в календаре
    func scheduleOutfit(outfitId: Int, date: Date, note: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        fetchCalendars { result in
            switch result {
            case .success(let calendars):
                guard let firstCalendar = calendars.first else {
                    print("Нет доступных календарей")
                    completion(.failure(NSError(domain: "No calendars available", code: 404)))
                    return
                }

                print("Используем календарь с id: \(firstCalendar.id)")
                self.createCalendarEntry(calendarId: firstCalendar.id, outfitId: outfitId, date: date, note: note, completion: completion)

            case .failure(let error):
                print("Ошибка при получении календарей: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func createCalendarEntry(calendarId: Int, outfitId: Int, date: Date, note: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/calendar/\(calendarId)/entry/create?calendarId=\(calendarId)") else {
            print("Невалидный URL для создания записи")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let body: [String: Any] = [
            "outfitId": outfitId,
            "date": formatter.string(from: date),
            "eventNote": note
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("Тело запроса на создание записи: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "—")")
        } catch {
            print("Ошибка сериализации тела запроса: \(error)")
            completion(.failure(error))
            return
        }

        print("Отправляем запрос на создание записи: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка сети при создании записи: \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Код ответа при создании записи: \(httpResponse.statusCode)")
                }

                if let data = data, let raw = String(data: data, encoding: .utf8) {
                    print("Ответ на создание записи:\n\(raw)")
                }

                if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                    print("Запись успешно создана")
                    completion(.success(()))
                } else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? 500
                    print("Ошибка создания записи: код \(code)")
                    completion(.failure(NSError(domain: "Server error", code: code)))
                }
            }
        }.resume()
    }

    func deleteScheduledOutfit(entryId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/calendar/entry/\(entryId)?entryId=\(entryId)") else {
            print("Невалидный URL для удаления записи")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept") 

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("Отправляем запрос на удаление записи: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка сети при удалении записи: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Статус удаления: \(httpResponse.statusCode)")

                    if (200...299).contains(httpResponse.statusCode) {
                        print("Запись успешно удалена")
                        completion(.success(()))
                    } else {
                        let code = httpResponse.statusCode
                        print("Ошибка удаления записи: код \(code)")

                        if let data = data, let raw = String(data: data, encoding: .utf8) {
                            print("Ответ ошибки:\n\(raw)")
                        }

                        completion(.failure(NSError(domain: "Server error", code: code)))
                    }
                } else {
                    print("Нет валидного ответа от сервера")
                    completion(.failure(NSError(domain: "No response", code: 500)))
                }
            }
        }.resume()
    }


}
