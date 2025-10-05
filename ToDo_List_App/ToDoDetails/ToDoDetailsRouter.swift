import UIKit

protocol ToDoDetailsRouterInputProtocol: AnyObject {}

class ToDoDetailsRouter: ToDoDetailsRouterInputProtocol {
    
}

enum ToDoDetailsBuilder {
    static func build(todo: ToDoDTO, output: ToDoDetailsModuleOutputProtocol) -> UIViewController {
        let view = ToDoDetailsView()
        let presenter = ToDoDetailsPresenter(todo: todo, output: output)
        view.output = presenter
        presenter.view = view
        
        return view
    }
}
