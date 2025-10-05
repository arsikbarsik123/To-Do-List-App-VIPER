protocol ToDoListInteractorInputProtocol {
    func fetchToDos()
}

protocol ToDoListInteractorOutputProtocol: AnyObject {
    func didLoad(toDos: [ToDoDTO])
    func failLoad(_ error: Error)
}

class ToDoListInteractor: ToDoListInteractorInputProtocol {
    weak var output: ToDoListInteractorOutputProtocol?
    let service: ToDoService
    
    init(service: ToDoService) {
        self.service = service
    }
    
    func fetchToDos() {
        service.fetchToDos { [weak self] result in
            switch result {
            case .success(let todos):
                self?.output?.didLoad(toDos: todos)
            case .failure(let error):
                self?.output?.failLoad(error)
            }
        }
    }
}
