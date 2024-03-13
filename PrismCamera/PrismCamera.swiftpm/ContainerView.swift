import Foundation
import SwiftUI

struct ContainerView: View {
    @State var launchViewIsPresented = true
    var body: some View {
        VStack {
            if launchViewIsPresented {
                LaunchView(launchViewIsPresented: $launchViewIsPresented)
            } else {
                DoubleCameraView(launchViewIsPresented: $launchViewIsPresented)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                withAnimation {
                    self.launchViewIsPresented = false
                }
            }
        }
    }
}
