import UIKit

protocol ToDoDetailsViewInputProtocol: AnyObject {
    func show(title: String, note: String, completed: Bool)
}

protocol ToDoDetailsViewOutputProtocol: AnyObject {
    func viewDidLoad()
    func titleChanged(_ text: String)
    func noteChanged(_ text: String)
    func completedChanged(_ value: Bool)
    func viewWillDisappear()
}

final class ToDoDetailsView: UIViewController {
    var output: ToDoDetailsViewControllerOutputProtocol?

    private let titleTextView = UITextView()
    private let noteLabel = UILabel()
    private let statusIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = true
        return icon
    }()

    private var isCompleted = false {
        didSet { statusIcon.isHidden = !isCompleted }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        output?.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output?.viewWillDisappear()
    }
}

// MARK: - ToDoDetailsViewControllerInputProtocol

extension ToDoDetailsView: ToDoDetailsViewControllerInputProtocol {
    func show(title: String, note: String, completed: Bool) {
        titleTextView.text = title
        noteLabel.text = note
        isCompleted = completed
    }
}


// MARK: - Setup

private extension ToDoDetailsView {
    func setupUI() {
        titleTextView.font = .preferredFont(forTextStyle: .title2)
        titleTextView.alwaysBounceVertical = true
        titleTextView.delegate = self

        noteLabel.font = .preferredFont(forTextStyle: .body)
        noteLabel.textColor = .secondaryLabel
        noteLabel.numberOfLines = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleCompleted))
        statusIcon.addGestureRecognizer(tap)

        let stack = UIStackView(arrangedSubviews: [statusIcon, titleTextView, noteLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            statusIcon.heightAnchor.constraint(equalToConstant: 28)
        ])

        titleTextView.becomeFirstResponder()
    }

    @objc func toggleCompleted() {
        isCompleted.toggle()
        output?.completedChanged(isCompleted)
    }
}

// MARK: - UITextViewDelegate

extension ToDoDetailsView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        output?.titleChanged(textView.text ?? "")
    }
}
