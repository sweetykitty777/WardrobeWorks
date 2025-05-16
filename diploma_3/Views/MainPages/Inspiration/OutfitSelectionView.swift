import SwiftUI

struct OutfitSelectionView: View {
    @Binding var selectedOutfit: Outfit?
    let outfits = MockData.outfits 

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(outfits) { outfit in
                        HStack {

                            if let imageName = outfit.imageName, let image = UIImage(named: imageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(outfit.name)
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            if outfit.id == selectedOutfit?.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .onTapGesture {
                            selectedOutfit = outfit
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Выберите аутфит")
        }
    }
}
