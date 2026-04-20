import SwiftUI

struct ContentView: View {
    @ObservedObject var store: TaskStore
    @ObservedObject var widgetController: DesktopWidgetController
    @ObservedObject var onboardingController: OnboardingController
    @State private var newTaskTitle = ""
    @State private var isHoveringClearAll = false

    private var pending: [TaskItem] { store.tasks.filter { !$0.isCompleted } }
    private var completed: [TaskItem] { store.tasks.filter { $0.isCompleted } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text("Antiva")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                if !store.tasks.isEmpty {
                    Text("\(pending.count) pendiente\(pending.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 12)

            // Add task
            HStack(spacing: 10) {
                TextField("Agregar tarea...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(Color(.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onSubmit { addTask() }

                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            Divider().padding(.horizontal, 16)

            // Task list
            if store.tasks.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(.quaternary)
                    Text("Sin tareas por ahora")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(pending) { task in
                            TaskRow(task: task, onToggle: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    store.toggleTask(task)
                                }
                            }, onDelete: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    store.deleteTask(task)
                                }
                            })
                        }

                        if !completed.isEmpty {
                            HStack {
                                Text("Completadas")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)

                                Spacer()

                                Button("Limpiar") {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        store.clearCompleted()
                                    }
                                }
                                .font(.system(size: 11))
                                .buttonStyle(.plain)
                                .foregroundStyle(.blue)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                            .padding(.bottom, 6)

                            ForEach(completed) { task in
                                TaskRow(task: task, onToggle: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        store.toggleTask(task)
                                    }
                                }, onDelete: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        store.deleteTask(task)
                                    }
                                })
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 400)
            }

            Divider().padding(.horizontal, 16)

            // Footer
            HStack {
                Button {
                    widgetController.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: widgetController.isVisible ? "eye.slash" : "eye")
                            .font(.system(size: 11))
                        Text("Widget")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)

                Spacer()

                if !store.tasks.isEmpty {
                    Button {
                        withAnimation { store.clearAll() }
                    } label: {
                        Text("Borrar todo")
                            .font(.system(size: 12))
                            .foregroundStyle(isHoveringClearAll ? .red : .secondary)
                    }
                    .buttonStyle(.plain)
                    .onHover { isHoveringClearAll = $0 }
                }

                Spacer()

                Button {
                    onboardingController.show()
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Text("Salir")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 360)
        .preferredColorScheme(.light)
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            store.addTask(title)
        }
        newTaskTitle = ""
    }
}

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(task.isCompleted ? .green : .gray.opacity(0.4))
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.system(size: 14))
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .lineLimit(2)

            Spacer()

            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .background(isHovering ? Color.black.opacity(0.04) : .clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}
