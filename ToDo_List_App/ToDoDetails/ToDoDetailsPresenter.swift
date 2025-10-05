
class ToDoDetailsPresenter: ToDoDetailsViewOutputProtocol {
    weak var view: ToDoDetailsViewInputProtocol?
    private let todo: ToDoDTO
    
    init(todo: ToDoDTO) {
        self.todo = todo
    }
    
    func viewDidLoad() {
        view?.show(
            title: todo.todo,
            body: "id: \(todo.id) • user: \(todo.userId)",
            isDone: todo.completed
        )
    }
}
