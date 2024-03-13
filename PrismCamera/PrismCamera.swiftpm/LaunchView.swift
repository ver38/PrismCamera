import Foundation
import SwiftUI

struct LaunchView: View {
    @State private var currentTextIndex = 0
    @Binding var launchViewIsPresented: Bool
    let texts = [
        "Discover a different world",
        "Reality transcends our visual understanding"
    ]
    
    
    var body: some View {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0, green: 0.5616535544, blue: 0.7800851464, alpha: 1)), Color(#colorLiteral(red: 0.003921568627, green: 0.1921568627, blue: 0.5607843137, alpha: 1))]), center: .center, startRadius: 1, endRadius: 600)
                    .ignoresSafeArea()
                
                
                VStack {
                    HStack {
                        ZStack {
                            
                            Image("SingleTriangle")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.white)
                                .offset(x: CGFloat(currentTextIndex) * 15)
                            
                            Image("SingleTriangle")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text(texts[currentTextIndex])
                        .foregroundColor(.white)
                        .padding()
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 3).repeatForever()) {
                                currentTextIndex = (currentTextIndex + 1) % texts.count
                            }
                        }
                }
        }
    }
}
