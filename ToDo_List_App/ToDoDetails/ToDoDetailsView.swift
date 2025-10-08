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
    private let titleField = UITextField()
    private let noteTextView = UITextView()
    private let notePlaceholder = UILabel()

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
        titleField.text = title
        noteTextView.text = note
        notePlaceholder.isHidden = !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


// MARK: - Setup

private extension ToDoDetailsView {
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        let topInset = noteTextView.textContainerInset.top
        let leftInset = noteTextView.textContainerInset.left + noteTextView.textContainer.lineFragmentPadding

        titleField.font = .preferredFont(forTextStyle: .title2)
        titleField.placeholder = "Название"
        titleField.clearButtonMode = .whileEditing
        titleField.addTarget(self, action: #selector(onTitleChanged), for: .editingChanged)

        noteTextView.font = .preferredFont(forTextStyle: .body)
        noteTextView.delegate = self
        noteTextView.isScrollEnabled = true
        noteTextView.backgroundColor = .clear

        notePlaceholder.text = "Заметка"
        notePlaceholder.textColor = .secondaryLabel
        notePlaceholder.font = .preferredFont(forTextStyle: .body)
        notePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.addSubview(notePlaceholder)
        NSLayoutConstraint.activate([
            notePlaceholder.topAnchor.constraint(equalTo: noteTextView.topAnchor, constant: topInset),
            notePlaceholder.leadingAnchor.constraint(equalTo: noteTextView.leadingAnchor, constant: leftInset),
            notePlaceholder.trailingAnchor.constraint(lessThanOrEqualTo: noteTextView.trailingAnchor,
                                                     constant: -(noteTextView.textContainerInset.right + noteTextView.textContainer.lineFragmentPadding))
        ])

        let stack = UIStackView(arrangedSubviews: [titleField, noteTextView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // ВАЖНО: даём высоту textView, иначе он 0 в UIStackView
            noteTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])

        titleField.becomeFirstResponder()
    }

    @objc private func onTitleChanged(_ sender: UITextField) {
        output?.titleChanged(sender.text ?? "")
    }

}

// MARK: - UITextViewDelegate

extension ToDoDetailsView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notePlaceholder.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        output?.noteChanged(textView.text ?? "")
    }
}

