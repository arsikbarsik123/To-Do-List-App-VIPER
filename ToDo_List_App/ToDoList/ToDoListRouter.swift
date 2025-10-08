import UIKit
import CoreData

protocol ToDoListRouterInputProtocol {
    func openDetails(objectID: NSManagedObjectID, in context: NSManagedObjectContext)
    func pop()
}

class ToDoListRouter: ToDoListRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func openDetails(objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
        let vc = ToDoDetailsBuilder.build(objectID: objectID, context: context)
        DispatchQueue.main.async {
            self.viewController?.navigationController?
                .pushViewController(vc, animated: true)
        }
    }
    
    func pop() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}

enum ToDoListBuilder {
    static func build() -> UIViewController {
        let view = ToDoListView()
        let router = ToDoListRouter()
        let interactor = ToDoListInteractor(
            storage: ToDoStorageImpl(),
            context: CoreDataStack.shared.viewContext,
            service: ToDoServiceImpl()
        )

        let presenter = ToDoListPresenter(interactor: interactor, router: router)
        
        view.output = presenter
        presenter.viewController = view
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}
