import UIKit

protocol ToDoListRouterInputProtocol {
    func openDetails(todo: ToDoDTO, output: ToDoDetailsModuleOutputProtocol)
    func pop()
}

class ToDoListRouter: ToDoListRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func openDetails(todo: ToDoDTO, output: ToDoDetailsModuleOutputProtocol) {
        let vc = ToDoDetailsBuilder.build(todo: todo, output: output)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pop() {
        viewController?.navigationController?.popViewController(animated: true)
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
