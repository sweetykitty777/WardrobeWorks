import Foundation

struct JWTDecoder {
    /// Проверка: истёк ли токен
    static func isTokenExpired(_ token: String) -> Bool {
        guard let payload = decodeJWTPart(token),
              let exp = payload["exp"] as? TimeInterval else {
            return true
        }

        let expirationDate = Date(timeIntervalSince1970: exp)
        print("Токен истекает: \(expirationDate)")
        return Date() >= expirationDate
    }

    /// Декодирует и возвращает дату истечения токена
    static func decodeExpiration(from token: String) -> Date? {
        guard let payload = decodeJWTPart(token),
              let exp = payload["exp"] as? TimeInterval else {
            print("Не удалось извлечь exp из токена")
            return nil
        }

        let expirationDate = Date(timeIntervalSince1970: exp)
        print("Дата истечения токена: \(expirationDate)")
        return expirationDate
    }

    /// Расшифровывает payload из токена
    private static func decodeJWTPart(_ token: String) -> [String: Any]? {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else { return nil }

        var base64String = segments[1]
        let requiredLength = (4 - base64String.count % 4) % 4
        base64String += String(repeating: "=", count: requiredLength)

        guard let data = Data(base64Encoded: base64String) else { return nil }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("Payload токена: \(json)")
            return json
        }

        return nil
    }
}

