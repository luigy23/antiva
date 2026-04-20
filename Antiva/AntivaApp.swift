import SwiftUI

@main
struct AntivaApp: App {
    @StateObject private var store = TaskStore()
    @StateObject private var widgetController = DesktopWidgetController()

    var body: some Scene {
        MenuBarExtra("Antiva", systemImage: "checklist") {
            ContentView(store: store, widgetController: widgetController)
                .onAppear {
                    widgetController.setUp(store: store)
                }
        }
        .menuBarExtraStyle(.window)
    }
}
