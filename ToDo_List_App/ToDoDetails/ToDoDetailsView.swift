import UIKit

protocol ToDoDetailsViewInputProtocol: AnyObject {
    func show(title: String, body: String, isDone: Bool)
}

protocol ToDoDetailsViewOutputProtocol {
    func viewDidLoad()
}

class ToDoDetailsView: UIViewController {
    var output: ToDoDetailsViewOutputProtocol!
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .title2)
        l.numberOfLines = 0

        return l
    }()
    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .body)
        l.numberOfLines = 0
        l.textColor = .secondaryLabel

        return l
    }()
    private let statusIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        icon.contentMode = .scaleAspectFit

        return icon
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDetailsUI()
        output.viewDidLoad()
    }
}

// MARK: - ToDoDetailsViewInputProtocol

extension ToDoDetailsView: ToDoDetailsViewInputProtocol {
    func show(title: String, body: String, isDone: Bool) {
        titleLabel.text = title
        bodyLabel.text = body
        statusIcon.isHidden = !isDone
    }
}

// MARK: - setupDetailsUI

extension ToDoDetailsView {
    func setupDetailsUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, statusIcon])
        stack.translatesAutoresizingMaskIntoConstraints = false

        statusIcon.setContentHuggingPriority(.required, for: .horizontal)

        view.addSubview(stack)
        view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}
