protocol ToDoDetailsModuleOutputProtocol: AnyObject {
    func detailsDidUpdate(id: Int, newText: String)
}

class ToDoDetailsPresenter {
    weak var view: ToDoDetailsViewInputProtocol?
    
    private let todo: ToDoDTO
    weak var output: ToDoDetailsModuleOutputProtocol?
    
    private var originalText: String
    private var currentText: String
    
    init(todo: ToDoDTO, output: ToDoDetailsModuleOutputProtocol) {
        self.todo = todo
        self.output = output
        self.originalText = todo.todo
        self.currentText = todo.todo
    }
}

extension ToDoDetailsPresenter: ToDoDetailsViewOutputProtocol {
    func viewWillDissapear() {
        let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != originalText, !trimmed.isEmpty else { return }
        output?.detailsDidUpdate(id: todo.id, newText: trimmed)
    }

    func didChangedText(_ text: String) {
        currentText = text
    }

    func viewDidLoad() {
        view?.show(title: todo.todo,
                   body: "id: \(todo.id) • user: \(todo.userId)",
                   isDone: todo.completed)
    }
}
