import Foundation

struct TaskItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

@MainActor
final class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] {
        didSet { save() }
    }

    private let key = "antiva_tasks"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = decoded
        } else {
            tasks = []
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func addTask(_ title: String) {
        tasks.append(TaskItem(title: title))
    }

    func toggleTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
    }

    func clearCompleted() {
        tasks.removeAll { $0.isCompleted }
    }

    func clearAll() {
        tasks.removeAll()
    }
}
