import UIKit

protocol ToDoListViewControllerInputProtocol: AnyObject {
    func show(items: [ToDoViewModel])
    func showLoading(_ isLoading: Bool)
    func showError(_ message: String)
    func showEmpty(_ message: String)
    func showErrorState(_ message: String)
    func askText(title: String, message: String?, initial: String?, submitTitle: String, completion: @escaping (String?) -> Void)
}

protocol ToDoListViewControllerOutputProtocol {
    func viewDidLoad()
    func didSelectRow(at index: Int)
    func didChangeSearch(text: String)
    func didPullToRefresh()
    func didTapRetry()
    func didFailLoad(_ message: String)
    func didSwipeDelete(at index: Int)
    func didToggleDone(at index: Int)
    func didTapAdd()
    func didSwipeEdit(at index: Int)
}

class ToDoListView: UITableViewController {
    var output: ToDoListViewControllerOutputProtocol!
    private var items: [ToDoViewModel] = []
    private let activity = UIActivityIndicatorView(style: .medium)
    private let search = UISearchController(searchResultsController: nil)
    private let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Задачи"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(onAdd)
            ),
            UIBarButtonItem(customView: activity)
        ]
        
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        navigationItem.searchController = search
        definesPresentationContext = true
        
        refresher.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
        
        output.viewDidLoad()
    }
    
    @objc func onAdd(_ sender: UIButton) {
        output.didTapAdd()
    }
}

// MARK: - Placeholder

private extension ToDoListView {
    func makePlaceholder(_ message: String) -> UIView {
        let label: UILabel = {
            let l = UILabel()
            l.text = message
            l.numberOfLines = 0
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textAlignment = .center
            
            return l
        }()
        
        let button: UIButton = {
            let b = UIButton()
            b.setTitle(message, for: .normal)
            b.addTarget(self, action: #selector(onRetry), for: .touchUpInside)
            
            return b
        }()
        
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
        
        return container
    }
    
    @objc func onRetry() {
        output.didTapRetry()
    }
}

// MARK: - UISearchResultsUpdating

extension ToDoListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        output.didChangeSearch(text: search.searchBar.text ?? "")
    }
    
    @objc func onRefresh() {
        output.didPullToRefresh()
    }
}

// MARK: - ToDoListViewControllerInputProtocol

extension ToDoListView: ToDoListViewControllerInputProtocol {
    func askText(
        title: String,
        message: String?,
        initial: String?,
        submitTitle: String,
        completion: @escaping (String?) -> Void
    ) {
        let a = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        a.addTextField {
            $0.text = initial
            $0.clearButtonMode = .whileEditing
        }
        a.addAction(
            UIAlertAction(
                title: "Oтмена",
                style: .cancel,
                handler: { _ in completion(nil) }
            )
        )
        a.addAction(
            UIAlertAction(
                title: submitTitle,
                style: .default,
                handler: { _ in
                    completion(a.textFields?.first?.text)
                }
            )
        )
        present(a, animated: true)
    }

    func showEmpty(_ message: String) {
        tableView.backgroundView = makePlaceholder(message)
        self.items = []
        tableView.reloadData()
    }
    
    func showErrorState(_ message: String) {
        tableView.backgroundView = makePlaceholder(message)
        self.items = []
        tableView.reloadData()
    }
    
    func show(items: [ToDoViewModel]) {
        tableView.backgroundView = nil
        self.items = items
        tableView.reloadData()
    }
    
    func showLoading(_ isLoading: Bool) {
        isLoading ? activity.startAnimating() : activity.stopAnimating()
        !isLoading ? refresher.endRefreshing() : ()
    }
    
    func showError(_ message: String) {
        let a = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a,animated: true)
    }
}

// MARK: - tableView

extension ToDoListView {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.didSelectRow(at: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var conf = UIListContentConfiguration.subtitleCell()
        
        conf.text = items[indexPath.row].title
        conf.secondaryText = items[indexPath.row].subTitle
        cell.contentConfiguration = conf
        cell.accessoryType = items[indexPath.row].isDone ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isDone = items[indexPath.row].isDone
        let title = isDone ? "Снять" : "Готово"
        
        let done = UIContextualAction(style: .normal, title: title) { [weak self] _, _, finish in
            self?.output.didToggleDone(at: indexPath.row)
            finish(true)
        }
        
        done.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(
            style: .normal,
            title: "Редактировать"
        ) { [weak self] _, _, finish in
            self?.output.didSwipeEdit(at: indexPath.row)
            finish(true)
        }
        
        let delete = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, finish in
            self?.output.didSwipeDelete(at: indexPath.row)
            finish(true)
        }
        return UISwipeActionsConfiguration(actions: [edit, delete])
    }
}
