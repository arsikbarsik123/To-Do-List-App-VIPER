import UIKit
import CoreData

protocol ToDoDetailsRouterInputProtocol: AnyObject { }

final class ToDoDetailsRouter: ToDoDetailsRouterInputProtocol {
    weak var viewController: UIViewController?
}

// MARK: - Builder

enum ToDoDetailsBuilder {
    static func build(objectID: NSManagedObjectID,
                      context: NSManagedObjectContext) -> UIViewController {
        let view = ToDoDetailsView()
        let interactor = ToDoDetailsInteractor()
        let router = ToDoDetailsRouter()
        let presenter = ToDoDetailsPresenter(view: view,
                                             interactor: interactor,
                                             router: router)

        view.output = presenter
        router.viewController = view

        interactor.configure(objectID: objectID, editingContext: context)

        return view
    }
}

