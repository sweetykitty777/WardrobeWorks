import SwiftUI

struct CachedImageView: View {
    let urlString: String
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat

    @State private var uiImage: UIImage?
    @State private var loadFailed = false

    init(
        urlString: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 12
    ) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .cornerRadius(cornerRadius)
            } else if loadFailed {
                errorPlaceholder
            } else {
                placeholder
            }
        }
        .onAppear {
            if uiImage == nil && !loadFailed {
                loadImage()
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(0.1))
            Image(systemName: "photo")
                .font(.system(size: 30))
                .foregroundColor(.gray)
        }
        .frame(width: width, height: height)
    }

    private var errorPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.red.opacity(0.1))
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 30))
                .foregroundColor(.red)
        }
        .frame(width: width, height: height)
    }

    private func loadImage() {
        if let cached = ImageCache.shared.image(forKey: urlString) {
            self.uiImage = cached
            return
        }

        guard let url = URL(string: urlString) else {
            self.loadFailed = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                ImageCache.shared.setImage(img, forKey: urlString)
                DispatchQueue.main.async {
                    self.uiImage = img
                }
            } else {
                DispatchQueue.main.async {
                    self.loadFailed = true
                }
            }
        }.resume()
    }
}
