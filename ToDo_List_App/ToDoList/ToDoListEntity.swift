import Foundation

struct ToDo {
    let id: Int
    let title: String
    let isDone: Bool
    let userId: Int
    let createdAt: Date?
}

struct ToDoDTO: Identifiable, Decodable {
    var id: Int
    var completed: Bool
    var todo: String
    var userId: Int
}

struct TodoListResponse: Decodable {
    let todos: [ToDoDTO]
}

struct ToDoViewModel {
    let title: String
    let note: String
    let subTitle: String
    let isDone: Bool
}

// MARK: - Domain

extension ToDo {
    init(dto: ToDoDTO, createdAt: Date? = nil) {
        self.id = dto.id
        self.title = dto.todo
        self.userId = dto.userId
        self.isDone = dto.completed
        self.createdAt = createdAt
    }
}

// MARK: - ViewModel

extension ToDoViewModel {
    init(todo: ToDoRecord, dateFormatter: DateFormatter? = nil) {
        self.title = todo.title ?? ""
        self.note = todo.note ?? ""
        if let d = todo.createdAt, let dateFormatter = dateFormatter {
            self.subTitle = dateFormatter.string(from: d)
        } else {
            self.subTitle = ""
        }
        self.isDone = todo.completed
    }
}
