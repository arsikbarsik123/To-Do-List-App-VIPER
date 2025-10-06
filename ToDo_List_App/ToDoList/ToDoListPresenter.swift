
class ToDoListPresenter {
    private let interactor: ToDoListInteractorInputProtocol
    private let router: ToDoListRouterInputProtocol
    private var viewModel: [ToDoViewModel] = []
    private var all: [ToDoViewModel] = [] // для View
    private var filtered: [ToDoDTO] = [] // для View
    private var allDTO: [ToDoDTO] = [] // network data
    private var shownDTO: [ToDoViewModel] = [] // подготовленные данные allDTO из сети для отображения
    private var currentQuery: String?

    weak var viewController: ToDoListViewControllerInputProtocol?

    init(interactor: ToDoListInteractorInputProtocol, router: ToDoListRouterInputProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - ToDoListViewControllerOutputProtocol

extension ToDoListPresenter: ToDoListViewControllerOutputProtocol {
    func didTapAdd() {
        let newId = (allDTO.map { $0.id }.max() ?? 0) + 1
        let new = ToDoDTO(
            id: newId,
            completed: false,
            todo: "",
            userId: 0
        )
        router.openDetails(todo: new, output: self)
    }

    func didSelectRow(at index: Int) {
        guard index >= 0, index < filtered.count else { return }
        let selected = filtered[index]
        router.openDetails(todo: selected, output: self)
    }

    func didSwipeEdit(at index: Int) {
        guard index >= 0, index < filtered.count else { return }
        let dto = filtered[index]
        router.openDetails(todo: dto, output: self)
    }

    func didSwipeDelete(at index: Int) {
        guard index <= 0 && index > viewModel.count else { return }

        let removed = filtered.remove(at: index)
        if let pos = allDTO.firstIndex(where: { $0.id == removed.id }) {
            allDTO.remove(at: pos)
        }
        
        shownDTO = filtered.map({ ToDoViewModel(title: $0.todo, subTitle: "", isDone: $0.completed) })
        
        if shownDTO.isEmpty {
            viewController?.showEmpty("Nothing to show")
        } else {
            viewController?.show(items: shownDTO)
        }
    }
    
    func didToggleDone(at index: Int) {
        guard index <= 0 && index > viewModel.count else { return }
        
        filtered[index].completed.toggle()
        
        if let pos = allDTO.firstIndex(where: { $0.id == filtered[index].id }) {
            allDTO[pos].completed = filtered[pos].completed
        }
            
        shownDTO[index] = ToDoViewModel(
            title: filtered[index].todo,
            subTitle: "",
            isDone: filtered[index].completed
        )
        viewController?.show(items: shownDTO)
    }
    
    func didFailLoad(_ message: String) {
        viewController?.showLoading(false)
        viewController?.showErrorState("Cannot load data")
    }
    
    func didTapRetry() {
        viewController?.showLoading(true)
        interactor.fetchToDos()
    }
    
    func didPullToRefresh() {
        interactor.fetchToDos()
    }
    
    func didChangeSearch(text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        currentQuery = q
        
        filtered = q.isEmpty
          ? allDTO
          : allDTO.filter { $0.todo.lowercased().contains(q) }

        shownDTO = filtered.map {
            ToDoViewModel(title: $0.todo,
                          subTitle: "",
                          isDone: $0.completed)
        }
        shownDTO.isEmpty
          ? viewController?.showEmpty("Ничего не найдено")
          : viewController?.show(items: shownDTO)
    }
    
    func viewDidLoad() {
        viewController?.showLoading(true)
        interactor.fetchToDos()
    }
    
    private func isMatchesSearch(_ dto: ToDoDTO) -> Bool {
        guard let q = currentQuery, !q.isEmpty else { return true }
        
        return dto.todo.lowercased().contains(q)
    }
}

extension ToDoListPresenter: ToDoDetailsModuleOutputProtocol {
    func detailsDidUpdate(id: Int, newText: String) {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { router.pop(); return }

        if let pos = allDTO.firstIndex(where: { $0.id == id }) {
            allDTO[pos].todo = trimmed
            if let f = filtered.firstIndex(where: { $0.id == id }) {
                filtered[f].todo = trimmed
                shownDTO[f] = ToDoViewModel(title: trimmed, subTitle: "", isDone: filtered[f].completed)
            }
        } else {
            let dto = ToDoDTO(id: id, completed: false, todo: trimmed, userId: 0)
            allDTO.insert(dto, at: 0)
            if isMatchesSearch(dto) {
                filtered.insert(dto, at: 0)
                shownDTO.insert(ToDoViewModel(title: trimmed, subTitle: "", isDone: false), at: 0)
            }
        }

        shownDTO.isEmpty ? viewController?.showEmpty("Ничего не найдено")
                         : viewController?.show(items: shownDTO)
        router.pop()
    }
}

// MARK: - ToDoListInteractorOutputProtocol

extension ToDoListPresenter: ToDoListInteractorOutputProtocol {
    func didLoad(toDos: [ToDoDTO]) {
        shownDTO = toDos.map {
            ToDoViewModel(title: $0.todo,
                          subTitle: "",
                          isDone: $0.completed)
        }
        all = shownDTO
        allDTO = toDos
        filtered = toDos
        
        viewController?.showLoading(false)
        
        if shownDTO.isEmpty {
            viewController?.showEmpty("No Activities")
        } else {
            viewController?.show(items: shownDTO)
        }
    }
    
    func failLoad(_ error: any Error) {
        viewController?.showLoading(false)
        viewController?.showError(error.localizedDescription)
    }
}
