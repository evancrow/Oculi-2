import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            InteractionViewWrapper(trackerModel: TrackerModel(avModel: AVModel())) {
                ContentView()
            }
        }
    }
}
