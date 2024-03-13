import SwiftUI
import Foundation
import AVFoundation
import UIKit
import CoreImage
import PhotosUI



public class PrismCameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Published var photoTaken: Bool = false
    
    @Published var captureSession = AVCaptureSession()
    
    @Published var alert: Bool = false
    
    // to read pic data
    @Published var output = AVCapturePhotoOutput()
    
    @Published var cameraLivePreview: AVCaptureVideoPreviewLayer!
    
    @Published var flashState: Bool = false
    
    @Published var filter: CIFilter?
    
    @Published var photoDidSave: Bool = false
    
    @Published var picData = Data(count: 0)
    
    @Published var filteredImage: UIImage?
    
    @State private var image: UIImage?
    
    @Published var capturedImage: UIImage?
    
    
    func checkAuthorization() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUpCamera()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUpCamera()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    
    func setUpCamera()  {
        do {
            self.captureSession.beginConfiguration()
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
            
            let input = try AVCaptureDeviceInput(device: device!)
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            if self.captureSession.canAddOutput(self.output) {
                self.captureSession.addOutput(self.output)
            }
            self.filter = DiplopiaFilter()
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    class DiplopiaFilter: CIFilter {
        @objc dynamic var inputImage: CIImage?
        @objc dynamic var inputOffset: CGFloat = 65.0
        
        override var outputImage: CIImage? {
            guard let inputImage = inputImage else { return nil }
            
            let preTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2))
            let rotatedImage = inputImage.transformed(by: preTransform)
            
            
            let transform = CGAffineTransform(translationX: inputOffset, y: 0)
            let offsetImage = rotatedImage.transformed(by: transform)
            let overlayFilter = CIFilter(name: "CIPinLightBlendMode")
            
            overlayFilter?.setValue(offsetImage, forKey: kCIInputBackgroundImageKey)
            overlayFilter?.setValue(rotatedImage, forKey: kCIInputImageKey)
            
            guard let combinedImage = overlayFilter?.outputImage else { return nil }
            
            let croppedImage = combinedImage.cropped(to: rotatedImage.extent)
            
            return croppedImage
        }
    }
    
    
    public func applyFilterToImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let cgImgResult = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        let filteredImage = UIImage(cgImage: cgImgResult)
        print("filtered the image all good")
        
        return filteredImage
    }
    
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        print("took the picture all good")
        
        guard let imageData = photo.fileDataRepresentation(), let originalImage = UIImage(data: imageData) else { return }
        if let filteredImage = applyFilterToImage(originalImage) {
            self.picData = filteredImage.jpegData(compressionQuality: 1.0) ?? Data()
        } else {
            self.picData = imageData
        }
        capturedImage = originalImage
        
        writeImage()
        
    }
    
    
    func capturePhoto() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                withAnimation{self.photoTaken.toggle()}
            }
        }
        
    }
    
    
    func captureAgain() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                withAnimation{self.photoTaken.toggle()}
                self.photoDidSave = false
                print("capture again")
            }
        }
    }
    
    
    func writeImage() {
        
        let image = UIImage(data: self.picData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.photoDidSave = true
        
        print("saved the picture all good")
    }
}







struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera : PrismCameraModel
    
    func makeUIView(context: Context) ->  UIView {
        
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.cameraLivePreview = AVCaptureVideoPreviewLayer(session: camera.captureSession)
        camera.cameraLivePreview.frame = view.frame
        
        camera.cameraLivePreview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.cameraLivePreview)
        
        camera.captureSession.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}

