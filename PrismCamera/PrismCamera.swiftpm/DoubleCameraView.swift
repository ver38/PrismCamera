import SwiftUI
import Foundation
import UIKit
import Photos

struct DoubleCameraView: View {
    
    @StateObject var camera = PrismCameraModel()
    
    @State private var selectedImage: ImageModel?
    
    @Binding var launchViewIsPresented: Bool
    
    @State var photoDidSave = false
    
    
    var body: some View {
        
        ZStack{
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            
            VStack {
                Spacer()
                HStack {
                    if !camera.photoTaken {
                        Button{ camera.capturePhoto() } label: {
                            Image("PrismCameraCustomButton")
                                .resizable()
                                .frame(width: 65, height: 65, alignment: .center)
                        }
                    }
                    else {
                        Button{ camera.captureAgain() } label: {
                            Image("PrismCameraCustomButton")
                                .resizable()
                                .frame(width: 65, height: 65, alignment: .center)
                        }
                    }
                }
                
                HStack {
                    
                    
                    Button{showLastTakenPhoto()} label: {
                        Text("Through my eyes")
                            .foregroundColor(.white)
                            .padding(.vertical,10)
                            .padding(.horizontal,10)
                            .background(
                                RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0, green: 0.5616535544, blue: 0.7800851464, alpha: 1)), Color(#colorLiteral(red: 0.003921568627, green: 0.1921568627, blue: 0.5607843137, alpha: 1))]), center: .center, startRadius: 5, endRadius: 80)
                            )
                        
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .onAppear(perform: {
            camera.checkAuthorization()
        })
        .fullScreenCover(item: $selectedImage) { item in
            if let image = item.image {
                ImagePreviewView(image: image, onClose: {
                    selectedImage = nil
                })
            }
        }
    }
    
    func showLastTakenPhoto() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let lastAsset = fetchResult.firstObject {
            let manager = PHImageManager.default()
            let targetSize = PHImageManagerMaximumSize
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            manager.requestImage(for: lastAsset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
                if let image = image {
                    self.selectedImage = ImageModel(id: UUID(), image: image)
                }
            }
        }
    }
}

