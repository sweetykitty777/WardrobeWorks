import SwiftUI

struct ErasePoint: Identifiable, Hashable {
    let id = UUID()
    let point: CGPoint
    let size: CGFloat

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ErasePoint, rhs: ErasePoint) -> Bool {
        lhs.id == rhs.id
    }
}

struct BackgroundEraserView: View {
    @State private var inputImage: UIImage
    let onFinish: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var erasePoints: [ErasePoint] = []
    @State private var brushSize: CGFloat = 40
    @State private var isAutoCropping = false
    @State private var progress: CGFloat = 0.0

    init(inputImage: UIImage, onFinish: @escaping (UIImage) -> Void) {
        _inputImage = State(initialValue: inputImage)
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let imageSize = inputImage.size
                let containerSize = geometry.size
                let fittedSize = aspectFitSize(for: imageSize, in: containerSize)

                ZStack {
                    Color.white

                    Image(uiImage: inputImage)
                        .resizable()
                        .frame(width: fittedSize.width, height: fittedSize.height)
                        .position(x: containerSize.width / 2, y: containerSize.height / 2)
                        .compositingGroup()
                        .overlay(
                            ZStack {
                                ForEach(erasePoints) { point in
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: point.size, height: point.size)
                                        .position(point.point)
                                }
                            }
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    erasePoints.append(ErasePoint(point: value.location, size: brushSize))
                                }
                        )
                }
            }
            .background(Color.white)
            .frame(maxHeight: .infinity)

            Divider()

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Размер кисти: \(Int(brushSize))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Slider(value: $brushSize, in: 10...100)
                        .accentColor(.blue)
                }
                .padding(.horizontal)

                if isAutoCropping {
                    VStack(spacing: 8) {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                        Text("Автообрезка изображения...")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                } else {
                    Button(action: startAutoCrop) {
                        HStack {
                            Image(systemName: "scissors")
                            Text("Автообрезка")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                Button(action: { erasePoints.removeAll() }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Очистить всё")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Button("Готово") {
                    let final = renderErasedImage()
                    onFinish(final)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color.white)
        }
        .ignoresSafeArea()
    }

    private func startAutoCrop() {
        guard let pngData = inputImage.pngData() else {
            print("Невозможно получить PNG")
            return
        }
        isAutoCropping = true
        progress = 0.1

        sendToRemoveBG(imageData: pngData) { result in
            DispatchQueue.main.async {
                isAutoCropping = false
                switch result {
                case .success(let newImg):
                    self.inputImage = newImg
                    self.erasePoints = []
                case .failure(let error):
                    print("Ошибка удаления фона:", error)
                }
            }
        }
    }

    private func sendToRemoveBG(imageData: Data, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/image-service/remove-bg/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        guard let token = KeychainHelper.get(forKey: "accessToken"), !token.isEmpty else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No access token"]
            )))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"input.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("Отправляем запрос на удаление фона: \(request.url?.absoluteString ?? "")")
        print("Request Method: \(request.httpMethod ?? "-")")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request Body size: \(body.count) bytes")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка сети при удалении фона: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                print("Нет HTTPURLResponse")
                completion(.failure(NSError(domain: "No HTTP response", code: 500)))
                return
            }

            print("Response Status Code: \(http.statusCode)")
            print("Response Headers: \(http.allHeaderFields)")

            if let data = data {
                if let bodyString = String(data: data, encoding: .utf8) {
                    print("Response Body (string):\n\(bodyString)")
                } else {
                    print("Response Body: <binary data, \(data.count) bytes>")
                }
            }

            // Проверяем успешный код и декодируем картинку
            guard (200..<300).contains(http.statusCode),
                  let data = data,
                  let resultImage = UIImage(data: data)
            else {
                completion(.failure(NSError(domain: "Server error", code: http.statusCode)))
                return
            }

            print("Фон успешно удалён, получена картинка размером \(resultImage.size)")
            completion(.success(resultImage))
        }
        .resume()
    }

    private func aspectFitSize(for imageSize: CGSize, in containerSize: CGSize) -> CGSize {
        let aspectRatio = imageSize.width / imageSize.height
        let containerRatio = containerSize.width / containerSize.height
        if aspectRatio > containerRatio {
            let width = containerSize.width
            return CGSize(width: width, height: width / aspectRatio)
        } else {
            let height = containerSize.height
            return CGSize(width: height * aspectRatio, height: height)
        }
    }

    private func renderErasedImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: inputImage.size)
        return renderer.image { ctx in
            inputImage.draw(in: CGRect(origin: .zero, size: inputImage.size))
            ctx.cgContext.setBlendMode(.clear)
            for p in erasePoints {
                let scale = inputImage.size.width / UIScreen.main.bounds.width
                let pt = CGPoint(x: p.point.x * scale, y: p.point.y * scale)
                let sz = p.size * scale
                let rect = CGRect(x: pt.x - sz/2, y: pt.y - sz/2, width: sz, height: sz)
                ctx.cgContext.fillEllipse(in: rect)
            }
        }
    }
}
