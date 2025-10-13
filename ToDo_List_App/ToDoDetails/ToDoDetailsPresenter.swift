import Foundation
import CoreData

final class ToDoDetailsPresenter {
    private weak var view: ToDoDetailsViewInputProtocol?
    private let interactor: ToDoDetailsInteractorInput
    private let router: ToDoDetailsRouterInputProtocol
    private let df: DateFormatter = {
        let f = DateFormatter()
        f.locale = .init(identifier: "ru_RU")
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    init(view: ToDoDetailsViewInputProtocol,
         interactor: ToDoDetailsInteractorInput,
         router: ToDoDetailsRouterInputProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - ToDoDetailsViewControllerOutputProtocol

extension ToDoDetailsPresenter: ToDoDetailsViewOutputProtocol {
    func viewDidLoad() {
        let s = interactor.snapshot()
        view?.show(title: s.title, note: s.note, completed: s.completed)
        let dateText = s.createdAt.map { df.string(from: $0) } ?? ""
        view?.setDate(dateText)
    }

    func titleChanged(_ text: String) {
        interactor.setTitle(text)
    }
    
    func noteChanged(_ text: String) {
        interactor.setNote(text)
    }
    
    func completedChanged(_ value: Bool) {
        interactor.setCompleted(value)
    }

    func viewWillDisappear() {
        interactor.commitChangesOnDisappear()
    }
}
