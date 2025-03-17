import Foundation
import SwiftUI

struct OutfitDetailView: View {
    let outfit: Outfit

    var body: some View {
        
        
        VStack {
            if let imageName = outfit.imageName, let image = UIImage(named: imageName){
             Image(uiImage: image)
                 .resizable()
                 .scaledToFit()
                 .frame(height: 200)
                 .padding(.top, 50)
             } else {
                 Image(systemName: "photo")
                     .resizable()
                     .scaledToFit()
                     .frame(height: 200)
                     .foregroundColor(.gray)
             }
            Text(outfit.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Text("Состав аутфита:")
                .font(.headline)
                .padding(.horizontal)


            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 40) {
                    ForEach(outfit.outfitItems, id: \.id) { item in
                        VStack {
                            if let imageName = item.imageName, let image = UIImage(named: imageName){
                             Image(uiImage: image)
                                 .resizable()
                                 .scaledToFit()
                                 .frame(height: 100)
                                 .clipShape(RoundedRectangle(cornerRadius: 10))
                                 .shadow(radius: 2)
                                 .padding(.top, 50)
                             } else {
                                 Image(systemName: "photo")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(height: 200)
                                     .foregroundColor(.gray)
                             }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle(outfit.name) 
        .navigationBarTitleDisplayMode(.inline)
    }
}
