import CoreData

class ToDoListPresenter {
    private let interactor: ToDoListInteractorInputProtocol
    private let router: ToDoListRouterInputProtocol
    private var viewModel: [ToDoViewModel] = []
    private var filtered: [ToDoDTO] = []
    private var allDTO: [ToDoDTO] = []
    private var shownDTO: [ToDoViewModel] = []
    private var currentQuery: String?
    private var visibleIDs: [NSManagedObjectID] = []

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
        _ = ToDoDTO(
            id: newId,
            completed: false,
            todo: "",
            userId: 0
        )
        interactor.addTapped()
    }

    func didSelectRow(at index: IndexPath) {
        interactor.edit(at: index)
    }

    func didSwipeEdit(at index: IndexPath) {
        interactor.edit(at: index)
    }

    func didSwipeDelete(at index: IndexPath) {
        interactor.delete(at: index)
    }
    
    func didToggleDone(at index: IndexPath) {
        interactor.toggleDone(at: index)
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
        viewController?.showLoading(true)
        interactor.fetchToDos()
    }
    
    func didChangeSearch(text: String) {
        currentQuery = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        reloadData()
    }
    
    func viewDidLoad() {
        interactor.start() 
    }
    
    private func isMatchesSearch(_ dto: ToDoDTO) -> Bool {
        guard let q = currentQuery, !q.isEmpty else { return true }
        
        return dto.todo.lowercased().contains(q)
    }
}

// MARK: - ToDoListInteractorOutputProtocol

extension ToDoListPresenter: ToDoListInteractorOutputProtocol {

    func reloadData() {
        viewController?.showLoading(false)

        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"

        var vms: [ToDoViewModel] = []
        let rows = interactor.numberOfRows
        vms.reserveCapacity(rows)

        for i in 0..<rows {
            let rec = interactor.model(at: IndexPath(row: i, section: 0))
            vms.append(ToDoViewModel(todo: rec, dateFormatter: df))
        }
        
        vms.isEmpty ? viewController?.showEmpty("Ничего не найдено")
                      : viewController?.show(items: vms)
    }

    func failLoad(_ error: Error) {
        viewController?.showLoading(false)
        viewController?.showError(error.localizedDescription)
    }

    func openDetails(objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
        router.openDetails(objectID: objectID, in: context)
    }
}
