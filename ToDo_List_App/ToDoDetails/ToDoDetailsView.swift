import UIKit

protocol ToDoDetailsViewInputProtocol: AnyObject {
    func show(title: String, body: String, isDone: Bool)
}

protocol ToDoDetailsViewOutputProtocol {
    func viewDidLoad()
    func didChangedText(_ text: String)
    func viewWillDissapear()
    
}

class ToDoDetailsView: UIViewController {
    var output: ToDoDetailsViewOutputProtocol!
    private let textView = UITextView()
    private let doneIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
    
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

        textViewSetup()
        setupDetailsUI()
        output.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingToParent || self.isBeingDismissed {
            output.viewWillDissapear()
        }
    }
}


// MARK: - UITextViewDelegate

extension ToDoDetailsView: UITextViewDelegate {
    func textViewSetup() {
        textView.font = .preferredFont(forTextStyle: .body)
        textView.delegate = self
        textView.alwaysBounceVertical = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        output.didChangedText(textView.text ?? "")
    }
}

// MARK: - ToDoDetailsViewInputProtocol

extension ToDoDetailsView: ToDoDetailsViewInputProtocol {
    func show(title: String, body: String, isDone: Bool) {
        titleLabel.text = title
        bodyLabel.text = body
        statusIcon.isHidden = !isDone
        textView.text = title
    }
}

// MARK: - setupDetailsUI

extension ToDoDetailsView {
    func setupDetailsUI() {
        let stack = UIStackView(arrangedSubviews: [statusIcon, textView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            statusIcon.heightAnchor.constraint(equalToConstant: 28)
        ])

        textView.font = .preferredFont(forTextStyle: .title2)
        textView.alwaysBounceVertical = true
        textView.delegate = self
        textView.becomeFirstResponder()
    }

}
