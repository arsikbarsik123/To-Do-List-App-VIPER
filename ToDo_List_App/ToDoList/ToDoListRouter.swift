import UIKit

protocol ToDoListRouterInputProtocol {
    func openDetails(todo: ToDoDTO)
}

class ToDoListRouter: ToDoListRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func openDetails(todo: ToDoDTO) {
        let vc = ToDoDetailsBuilder.build(todo: todo)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

enum ToDoListBuilder {
    static func build() -> UIViewController {
        let view = ToDoListView()
        let router = ToDoListRouter()
        let interactor = ToDoListInteractor(service: ToDoServiceImpl())
        let presenter = ToDoListPresenter(interactor: interactor, router: router)
        
        view.output = presenter
        presenter.viewController = view
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}
