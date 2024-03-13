import SwiftUI

struct ImagePreviewView: View {
    @ObservedObject var camera = PrismCameraModel()
    var image: UIImage
    var onClose: () -> Void
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                  //  .ignoresSafeArea()
                
                Button(action: onClose) {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .padding()
                        .alignmentGuide(.top) { dimension in
                            dimension[.top]
                        }
                        .alignmentGuide(.trailing) { dimension in
                            dimension[.trailing]
                        }
                }
            }
        }
    }
}

struct ImageModel: Identifiable {
    let id: UUID
    let image: UIImage?
}

