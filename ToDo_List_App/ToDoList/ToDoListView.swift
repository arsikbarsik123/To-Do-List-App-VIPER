import UIKit
import CoreData

protocol ToDoListViewControllerInputProtocol: AnyObject {
    func show(items: [ToDoViewModel])
    func showLoading(_ isLoading: Bool)
    func showError(_ message: String)
    func showEmpty(_ message: String)
    func showErrorState(_ message: String)
    func reloadData()
}

protocol ToDoListViewControllerOutputProtocol {
    func viewDidLoad()
    func didSelectRow(at index: IndexPath)
    func didChangeSearch(text: String)
    func didPullToRefresh()
    func didTapRetry()
    func didFailLoad(_ message: String)
    func didSwipeDelete(at index: IndexPath)
    func didToggleDone(at index: IndexPath)
    func didTapAdd()
    func didSwipeEdit(at index: IndexPath)
}

class ToDoListView: UITableViewController {
    var output: ToDoListViewControllerOutputProtocol?
    private let bar = UIView()
    private var items: [ToDoViewModel] = []
    private let activity = UIActivityIndicatorView(style: .medium)
    private let search = UISearchController(searchResultsController: nil)
    private let refresher = UIRefreshControl()
    private let longPress: UILongPressGestureRecognizer = {
        let g = UILongPressGestureRecognizer()
        g.minimumPressDuration = 0.4
        g.cancelsTouchesInView = false
        return g
    }()
    private let addButton = UIButton(type: .system)
    private let counterLabel = UILabel()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ToDoCell.self, forCellReuseIdentifier: "ToDoCell")
        tableView.addGestureRecognizer(longPress)
        
        setupNavTitle()
        blackTableView()
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        refresher.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
        
        tableView.contentInset.bottom += 70
        tableView.scrollIndicatorInsets.bottom += 70
        
        setupBottomPanel()
        output?.viewDidLoad()
        
        let req: NSFetchRequest<ToDoRecord> = ToDoRecord.fetchRequest()
    }
}

// MARK: - Design

private extension ToDoListView {
    func setupNavTitle() {
        navigationItem.title = "Задачи"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .black
        ap.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        ap.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.compactAppearance = ap
        navigationController?.navigationBar.tintColor = .white
    }
    
    func blackTableView() {
        tableView.backgroundColor = .black
        tableView.indicatorStyle = .white
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        if #available(iOS 15.0, *) {
            tableView.separatorInsetReference = .fromCellEdges
        } else {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }

        tableView.tableFooterView = UIView()

        let tf = search.searchBar.searchTextField
        tf.backgroundColor = UIColor(white: 0.12, alpha: 1)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.systemGray]
        )
    }
}

// MARK: - bottomPanel

private extension ToDoListView {
    func setupBottomPanel() {
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 0
        bar.layer.masksToBounds = false
        bar.backgroundColor = .darkGray
        guard let host = navigationController?.view else { return }
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setPreferredSymbolConfiguration(.init(pointSize: 17, weight: .semibold), forImageIn: .normal)
        addButton.tintColor = .systemYellow
        addButton.addTarget(self, action: #selector(onAdd), for: .touchUpInside)
        
        counterLabel.textColor = .white
        counterLabel.font = .preferredFont(forTextStyle: .footnote)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.textAlignment = .center
        counterLabel.text = "\(items.count) " + tasksWordRu(for: items.count)
        
        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.plain()
            cfg.image = UIImage(systemName: "square.and.pencil")
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            addButton.configuration = cfg
        } else {
            addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            addButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }

        
        host.addSubview(bar)
        bar.addSubview(addButton)
        bar.addSubview(counterLabel)
        
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: host.bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: 70),
            
            counterLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            counterLabel.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            counterLabel.widthAnchor.constraint(equalToConstant: 100),
            counterLabel.heightAnchor.constraint(equalToConstant: 20),

            addButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -12),
            addButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 28),
            addButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func tasksWordRu(for n: Int) -> String {
        let n = n % 100
        let n1 = n % 10
        if n > 10 && n < 20 { return "задач" }
        if n1 == 1 { return "задача" }
        if (2...4).contains(n1) { return "задачи" }
        return "задач"
    }

    @objc private func onAdd() { output?.didTapAdd() }
}

// MARK: - Placeholder

private extension ToDoListView {
    func makePlaceholder(_ message: String) -> UIView {
        let label = UILabel()
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center

        let button = UIButton(type: .system)
        button.setTitle("Повторить", for: .normal)
        button.addTarget(self, action: #selector(onRetry), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor
                .constraint(
                    greaterThanOrEqualTo: container.safeAreaLayoutGuide.leadingAnchor,
                    constant: 16
                ),
            stack.trailingAnchor
                .constraint(
                    lessThanOrEqualTo: container.safeAreaLayoutGuide.trailingAnchor,
                    constant: -16
                )
        ])

        return container
    }
    
    @objc func onRetry() {
        output?.didTapRetry()
    }
}

// MARK: - UISearchResultsUpdating

extension ToDoListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        output?.didChangeSearch(text: search.searchBar.text ?? "")
    }
    
    @objc func onRefresh() {
        output?.didPullToRefresh()
    }
}

// MARK: - ToDoListViewControllerInputProtocol

extension ToDoListView: ToDoListViewControllerInputProtocol {
    func reloadData() {
        tableView.reloadData()
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
        counterLabel.text = "\(items.count) " + tasksWordRu(for: items.count)
        tableView.reloadData()
    }
    
    func showLoading(_ isLoading: Bool) {
        refresher.endRefreshing()
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
        output?.didSelectRow(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ToDoCell",
            for: indexPath
        ) as? ToDoCell else {
            fatalError()
        }
        
        let item = items[indexPath.row]
        let note = item.note
        
        cell.configure(title: item.title, note: note, date: item.subTitle, done: item.isDone)
        cell.selectionStyle = .none
        cell.backgroundColor = .black
        cell.setSeparatorHidden(indexPath.row == items.count - 1)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: indexPath as NSCopying,
                                          previewProvider: {
            return nil
        }, actionProvider: { [weak self] _ in

            let edit = UIAction(title: "Редактировать",
                                image: UIImage(systemName: "square.and.pencil")) { _ in
                self?.output?.didSwipeEdit(at: indexPath)
            }

            let share = UIAction(title: "Поделиться",
                                 image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self?.didSelectShare(at: indexPath.row)
            }

            let delete = UIAction(title: "Удалить",
                                  image: UIImage(systemName: "trash"),
                                  attributes: [.destructive]) { _ in
                self?.output?.didSwipeDelete(at: indexPath)
            }

            return UIMenu(title: "", children: [edit, share, delete])
        })
    }
    
    // share button
    private func didSelectShare(at index: Int) {
        let item = items[index]

        var activityItems: [Any] = [item.title]
        let note = item.subTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !note.isEmpty { activityItems.append(note) }

        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView,
                            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                            animator: UIContextMenuInteractionCommitAnimating) {
        if let vc = animator.previewViewController {
            animator.addCompletion { [weak self] in
                self?.show(vc, sender: self)
            }
        }
    }
}
