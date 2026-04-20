import SwiftUI

@main
struct AntivaApp: App {
    @StateObject private var store = TaskStore()
    @StateObject private var widgetController = DesktopWidgetController()
    @StateObject private var onboardingController = OnboardingController()

    var body: some Scene {
        MenuBarExtra("Antiva", systemImage: "checklist") {
            ContentView(store: store, widgetController: widgetController, onboardingController: onboardingController)
                .onAppear {
                    widgetController.setUp(store: store)
                    onboardingController.showIfFirstLaunch()
                }
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
final class OnboardingController: ObservableObject {
    private var window: NSWindow?
    private let hasSeenKey = "antiva_has_seen_onboarding"

    var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: hasSeenKey)
    }

    func showIfFirstLaunch() {
        guard !hasSeenOnboarding else { return }
        show()
    }

    func show() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 380),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        w.titlebarAppearsTransparent = true
        w.titleVisibility = .hidden
        w.isMovableByWindowBackground = true
        w.center()
        w.level = .floating

        let content = OnboardingView {
            UserDefaults.standard.set(true, forKey: self.hasSeenKey)
            w.close()
        }
        w.contentView = NSHostingView(rootView: content)
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = w
    }
}
