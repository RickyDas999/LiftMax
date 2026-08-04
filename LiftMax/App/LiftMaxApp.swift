import SwiftUI

@main
struct LiftMaxApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(appModel)
        }
    }
}
