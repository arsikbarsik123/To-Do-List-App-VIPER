import UIKit

protocol ToDoDetailsRouterInputProtocol {}

class ToDoDetailsRouter: ToDoDetailsRouterInputProtocol {
    
}

enum ToDoDetailsBuilder {
    static func build(todo: ToDoDTO) -> UIViewController {
        let view = ToDoDetailsView()
        let presenter = ToDoDetailsPresenter(todo: todo)
        view.output = presenter
        presenter.view = view
        
        return view
    }
}
