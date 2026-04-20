import SwiftUI
import AppKit

@MainActor
final class DesktopWidgetController: ObservableObject {
    @Published var isVisible = false
    private var panel: NSPanel?
    private var store: TaskStore?
    private var isSetUp = false

    func setUp(store: TaskStore) {
        guard !isSetUp else { return }
        self.store = store
        isSetUp = true
        if UserDefaults.standard.bool(forKey: "antiva_widget_visible") {
            show()
        }
    }

    func toggle() {
        if isVisible { hide() } else { show() }
    }

    func show() {
        guard let store else { return }
        if panel == nil { createPanel(store: store) }
        panel?.orderFront(nil)
        isVisible = true
        UserDefaults.standard.set(true, forKey: "antiva_widget_visible")
    }

    func hide() {
        panel?.orderOut(nil)
        isVisible = false
        UserDefaults.standard.set(false, forKey: "antiva_widget_visible")
    }

    private func createPanel(store: TaskStore) {
        let width: CGFloat = 250
        let height: CGFloat = 360
        let frame = savedFrame(width: width, height: height)

        let p = NSPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.level = .floating
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.isMovableByWindowBackground = true
        p.hidesOnDeactivate = false
        p.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        p.animationBehavior = .utilityWindow

        let content = DesktopWidgetView(store: store)
        p.contentView = NSHostingView(rootView: content)

        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: p,
            queue: .main
        ) { [weak p] _ in
            Task { @MainActor in
                guard let frame = p?.frame else { return }
                UserDefaults.standard.set(Double(frame.origin.x), forKey: "antiva_widget_x")
                UserDefaults.standard.set(Double(frame.origin.y), forKey: "antiva_widget_y")
            }
        }

        self.panel = p
    }

    private func savedFrame(width: CGFloat, height: CGFloat) -> NSRect {
        let x = CGFloat(UserDefaults.standard.double(forKey: "antiva_widget_x"))
        let y = CGFloat(UserDefaults.standard.double(forKey: "antiva_widget_y"))
        if x != 0 || y != 0 {
            return NSRect(x: x, y: y, width: width, height: height)
        }
        if let screen = NSScreen.main {
            let sf = screen.visibleFrame
            return NSRect(x: sf.maxX - width - 40, y: sf.maxY - height - 40,
                          width: width, height: height)
        }
        return NSRect(x: 100, y: 100, width: width, height: height)
    }
}

// MARK: - Desktop Widget View

struct DesktopWidgetView: View {
    @ObservedObject var store: TaskStore

    private var pending: [TaskItem] { store.tasks.filter { !$0.isCompleted } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checklist")
                    .font(.system(size: 13))
                    .foregroundStyle(.blue)
                Text("Antiva")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                if !pending.isEmpty {
                    Text("\(pending.count)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.blue))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 12)

            if pending.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                    Text(String(localized: "all_done"))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(pending) { task in
                            WidgetTaskRow(task: task) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    store.toggleTask(task)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .frame(width: 250, height: 360)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        .preferredColorScheme(.light)
    }
}

struct WidgetTaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: "circle")
                    .font(.system(size: 14))
                    .foregroundStyle(isHovering ? .blue : .gray.opacity(0.4))
                Text(task.title)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(isHovering ? Color.blue.opacity(0.06) : .clear)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
