import CoreData

class ToDoListPresenter {
    private let interactor: ToDoListInteractorInputProtocol
    private let router: ToDoListRouterInputProtocol
    private var viewModel: [ToDoViewModel] = []
    
    private var filtered: [ToDoDTO] = [] // для View
    private var allDTO: [ToDoDTO] = [] // network data
    private var shownDTO: [ToDoViewModel] = [] // подготовленные данные allDTO из сети для отображения
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
        let new = ToDoDTO(
            id: newId,
            completed: false,
            todo: "",
            userId: 0
        )
        interactor.addTapped()
    }

    func didSelectRow(at index: Int) {
        guard index >= 0, index < visibleIDs.count else { return }
        interactor.edit(objectID: visibleIDs[index])
    }

    func didSwipeEdit(at index: Int) {
        guard index >= 0, index < visibleIDs.count else { return }
        interactor.edit(objectID: visibleIDs[index])
    }

    func didSwipeDelete(at index: Int) {
        guard index >= 0, index < visibleIDs.count else { return }
        interactor.delete(objectID: visibleIDs[index])
    }
    
    func didToggleDone(at index: Int) {
        guard index >= 0, index < visibleIDs.count else { return }
        interactor.toggleDone(objectID: visibleIDs[index])
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
//        viewController?.showLoading(true)
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
        df.dateStyle = .short
        df.timeStyle = .none

        var items: [ToDoViewModel] = []
        var ids: [NSManagedObjectID] = []

        let rows = interactor.numberOfRows
        for row in 0..<rows {
            let rec = interactor.model(at: IndexPath(row: row, section: 0))
            if let q = currentQuery, !q.isEmpty,
               !(rec.title ?? "").lowercased().contains(q) { continue }

            ids.append(rec.objectID)
            items.append(.init(title: rec.title ?? "",
                               subTitle: rec.createdAt.map { df.string(from: $0) } ?? "",
                               isDone: rec.completed))
        }

        visibleIDs = ids
        items.isEmpty ? viewController?.showEmpty("Ничего не найдено")
                      : viewController?.show(items: items)
    }


    func failLoad(_ error: Error) {
        viewController?.showLoading(false)
        viewController?.showError(error.localizedDescription)
    }

    func openDetails(objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
        router.openDetails(objectID: objectID, in: context)
    }
}
