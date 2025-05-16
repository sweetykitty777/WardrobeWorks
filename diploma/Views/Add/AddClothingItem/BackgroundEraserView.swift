import SwiftUI

struct BackgroundEraserView: View {
    @StateObject private var viewModel: BackgroundEraserViewModel
    let onFinish: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var imageFrame: CGRect = .zero

    init(inputImage: UIImage, onFinish: @escaping (UIImage) -> Void) {
        _viewModel = StateObject(wrappedValue: BackgroundEraserViewModel(image: inputImage))
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let insets = geometry.safeAreaInsets
                let safeWidth = geometry.size.width - insets.leading - insets.trailing
                let safeHeight = geometry.size.height - insets.top - insets.bottom

                let imageSize = viewModel.aspectFitSize(
                    for: viewModel.inputImage.size,
                    in: CGSize(width: safeWidth, height: safeHeight)
                )

                let imageOrigin = CGPoint(
                    x: (geometry.size.width - imageSize.width) / 2,
                    y: (geometry.size.height - imageSize.height) / 2
                )

                let frame = CGRect(origin: imageOrigin, size: imageSize)

                ZStack {
                    Color.white

                    Image(uiImage: viewModel.inputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize.width, height: imageSize.height)
                        .position(x: imageOrigin.x + imageSize.width / 2, y: imageOrigin.y + imageSize.height / 2)
                        .compositingGroup()
                        .overlay(drawingOverlay(in: frame))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if frame.contains(value.location) {
                                        viewModel.addErasePoint(at: value.location)
                                    }
                                }
                        )
                        .onAppear {
                            imageFrame = frame
                        }
                }
                .edgesIgnoringSafeArea(.all)
            }

            Divider()
            controls
        }
        .ignoresSafeArea()
    }

    private func drawingOverlay(in frame: CGRect) -> some View {
        ZStack {
            ForEach(viewModel.erasePoints) { point in
                Circle()
                    .fill(Color.white)
                    .frame(width: point.size, height: point.size)
                    .position(point.point)
            }
        }
        .frame(width: frame.width, height: frame.height)
        .position(x: frame.midX, y: frame.midY)
    }

    private var controls: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Размер кисти: \(Int(viewModel.brushSize))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Slider(value: $viewModel.brushSize, in: 10...100)
                    .accentColor(.blue)
            }
            .padding(.horizontal)

            if viewModel.isAutoCropping {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)
            } else {
                Button(action: {
                    viewModel.startAutoCrop {}
                }) {
                    Label("Автообрезка", systemImage: "scissors")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            Button(action: viewModel.clearAll) {
                Label("Очистить всё", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button("Готово") {
                let result = viewModel.renderErasedImage(imageFrameInView: imageFrame)
                onFinish(result)
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
}
