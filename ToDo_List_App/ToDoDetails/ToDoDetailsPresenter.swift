import Foundation
import CoreData

protocol ToDoDetailsViewControllerInputProtocol: AnyObject {
    func show(title: String, note: String, completed: Bool)
}

protocol ToDoDetailsViewControllerOutputProtocol: AnyObject {
    func viewDidLoad()
    func titleChanged(_ text: String)
    func noteChanged(_ text: String)
    func completedChanged(_ value: Bool)
    func viewWillDisappear()
}

final class ToDoDetailsPresenter {

    private weak var view: ToDoDetailsViewControllerInputProtocol?
    private let interactor: ToDoDetailsInteractorInput
    private let router: ToDoDetailsRouterInputProtocol

    init(view: ToDoDetailsViewControllerInputProtocol,
         interactor: ToDoDetailsInteractorInput,
         router: ToDoDetailsRouterInputProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - ToDoDetailsViewControllerOutputProtocol

extension ToDoDetailsPresenter: ToDoDetailsViewControllerOutputProtocol {
    func viewDidLoad() {
        if let s = interactor.snapshot() {
            view?.show(title: s.title, note: s.note, completed: s.completed)
        }
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
