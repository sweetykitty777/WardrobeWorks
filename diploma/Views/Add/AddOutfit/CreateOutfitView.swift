import SwiftUI

struct CreateOutfitView: View {
    @ObservedObject var viewModel: OutfitViewModel
    @StateObject private var wardrobeViewModel = WardrobeViewModel()

    @State private var showingWardrobe = false
    @State private var placedItems: [PlacedClothingItem] = []
    @State private var imageURLsByClothId: [Int: String] = [:]
    
    @State private var selectedWardrobeName: String = "Выбрать гардероб"
    @State private var selectedWardrobeId: Int?
    @State private var isSaving = false
    @State private var renderedImages: [Int: UIImage] = [:]
    @Environment(\.presentationMode) var presentationMode
    
    
    // === Для тоста ===
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isErrorToast = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                wardrobeMenu

                canvasView
                    .frame(height: 400)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1)
                    .padding(.horizontal)

                actionButtons

                Spacer()
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Создать аутфит")
            .sheet(isPresented: $showingWardrobe) {
                if let id = selectedWardrobeId {
                    WardrobeSelectionView(
                        selectedItems: $placedItems,
                        wardrobeId: id,
                        imageURLs: $imageURLsByClothId
                    )
                }
            }
            .onAppear {
                wardrobeViewModel.fetchWardrobes()
            }.overlay(
                Group {
                    if showToast {
                        ToastView(message: toastMessage)
                            .transition(.opacity)
                            .padding()
                    }
                }
            )
        }
    }

    private var wardrobeMenu: some View {
        Menu {
            ForEach(wardrobeViewModel.wardrobes, id: \..id) { wardrobe in
                Button(wardrobe.name) {
                    selectedWardrobeName = wardrobe.name
                    selectedWardrobeId = wardrobe.id
                }
            }
        } label: {
            HStack {
                Text(selectedWardrobeName)
                    .foregroundColor(selectedWardrobeId == nil ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }

    private var canvasView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear

                ForEach($placedItems, id: \..clothId) { $item in
                    if let imageURL = imageURLsByClothId[item.clothId] {
                        DraggableItem(
                            item: $item,
                            imageURL: imageURL,
                            canvasSize: geometry.size,
                            onDelete: {
                                placedItems.removeAll { $0.clothId == item.clothId }
                            }
                        )
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                if selectedWardrobeId != nil {
                    showingWardrobe = true
                }
            }) {
                Label("Добавить вещи", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1)
                    .padding(.horizontal)
            }

            Button(action: startSavingOutfit) {
                Text(isSaving ? "Сохранение..." : "Сохранить аутфит")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSaving ? Color.gray.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(isSaving)
        }
    }


    private func preloadImages(for items: [PlacedClothingItem], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var success = true

        for item in items {
            guard let urlString = imageURLsByClothId[item.clothId],
                  let url = URL(string: urlString) else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        renderedImages[item.clothId] = image
                    }
                } else {
                    success = false
                    print("Не удалось загрузить картинку для clothId \(item.clothId): \(error?.localizedDescription ?? "unknown error")")
                }
            }.resume()
        }

        group.notify(queue: .main) {
            completion(success)
        }
    }

    private func startSavingOutfit() {
        guard let wardrobeId = selectedWardrobeId else {
            print("Выберите гардероб")
            return
        }

        isSaving = true

        // 1. Скачиваем все картинки вещей
        preloadImages(for: placedItems) { success in
            guard success else {
                print("Не удалось загрузить все изображения")
                isSaving = false
                return
            }

            // 2. Высчитываем размер холста
            let canvasSize = canvasSizeForRendering(from: placedItems)

            // 3. Рендерим итоговое изображение с прозрачным фоном
            OutfitImageBuilder.renderImage(
                from: placedItems,
                images: renderedImages,
                canvasSize: canvasSize
            ) { image in
                guard let image = image else {
                    print("Не удалось срендерить изображение")
                    isSaving = false
                    return
                }

                // 4. Сохраняем локально для отладки (пусть будет PNG!)
                if let data = image.pngData() {
                    let url = getDocumentsDirectory().appendingPathComponent("preview-outfit.png")
                    try? data.write(to: url)
                    print("Локально PNG сохранён по пути:", url)
                }

                // 5. И наконец – грузим именно PNG, чтобы сохранить прозрачность
                ImageUploadService.shared.uploadPNGImage(image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let imagePath):
                            // После успешного аплоада сразу создаём аутфит на бэке
                            actuallySaveOutfit(imagePath: imagePath)
                        case .failure(let error):
                            print("Ошибка загрузки PNG:", error)
                            isSaving = false
                        }
                    }
                }
            }
        }
    }


    private func actuallySaveOutfit(imagePath: String) {
        guard let wardrobeId = selectedWardrobeId else { return }

        let placements = placedItems.map {
            OutfitClothPlacement(
                clothId: $0.clothId,
                x: $0.x,
                y: $0.y,
                rotation: $0.rotation,
                scale: $0.scale,
                zindex: $0.zIndex
            )
        }

        let outfitRequest = CreateOutfitRequest(
            name: "Новый аутфит",
            description: "",
            wardrobeId: wardrobeId,
            imagePath: imagePath,
            clothes: placements
        )

        print("Тело запроса:")
        if let json = try? JSONEncoder().encode(outfitRequest),
           let jsonString = String(data: json, encoding: .utf8) {
            print(jsonString)
        }

        OutfitService.shared.createOutfit(request: outfitRequest) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    toastMessage = "Аутфит успешно создан"
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                case .failure(let error):
                    toastMessage = "Ошибка создания аутфита"
                    showToast = true
                    print("Ошибка создания аутфита: \(error)")
                }
            }
        }
    }

    private func canvasSizeForRendering(from items: [PlacedClothingItem]) -> CGSize {
        guard !items.isEmpty else { return CGSize(width: 300, height: 400) }

        let padding: CGFloat = 100

        let maxX = items.map { $0.x + 50 * $0.scale }.max() ?? 0
        let maxY = items.map { $0.y + 50 * $0.scale }.max() ?? 0

        let width = max(maxX + padding, 300)
        let height = max(maxY + padding, 400)

        return CGSize(width: width, height: height)
    }

    func saveImageLocally(_ image: UIImage) {
        guard let data = image.pngData() else { // PNG для прозрачности
            print("Не удалось сконвертировать в PNG")
            return
        }

        let filename = getDocumentsDirectory().appendingPathComponent("preview-outfit.png")

        do {
            try data.write(to: filename)
            print("Изображение сохранено локально по пути: \(filename)")
        } catch {
            print("Ошибка при сохранении локального файла: \(error)")
        }
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func showToastWith(message: String, isError: Bool) {
        toastMessage = message
        isErrorToast = isError
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}
