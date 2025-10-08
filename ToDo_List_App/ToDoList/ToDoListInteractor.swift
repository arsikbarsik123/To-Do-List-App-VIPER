import Foundation
import CoreData

protocol ToDoListInteractorInputProtocol {
    func fetchToDos()
    func start()
    func delete(objectID: NSManagedObjectID)
    func toggleDone(objectID: NSManagedObjectID)
    func edit(objectID: NSManagedObjectID)
    var numberOfRows: Int { get }
    func model(at indexPath: IndexPath) -> ToDoRecord
    func addTapped()
}

protocol ToDoListInteractorOutputProtocol: AnyObject {
    func reloadData()
//    func didLoad(toDos: [ToDoDTO])
    func failLoad(_ error: Error)
    func openDetails(objectID: NSManagedObjectID, in context: NSManagedObjectContext)
}

final class ToDoListInteractor: NSObject {
    private let storage: ToDoStorage
    private let context: NSManagedObjectContext
    private let service: ToDoService
    private let seedFlagKey = "todos_seeded_v1"

    weak var output: ToDoListInteractorOutputProtocol?

    private lazy var frc: NSFetchedResultsController<ToDoRecord> = {
        let r: NSFetchRequest<ToDoRecord> = ToDoRecord.fetchRequest()
        r.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: r,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()

    init(
        storage: ToDoStorage = ToDoStorageImpl(),
        context: NSManagedObjectContext = CoreDataStack.shared.viewContext,
        service: ToDoService = ToDoServiceImpl()
    ) {
        self.storage = storage
        self.context = context
        self.service = service
        super.init()
    }
}

extension ToDoListInteractor: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        output?.reloadData()
    }
}

extension ToDoListInteractor: ToDoListInteractorInputProtocol {
    private func ensureFetched() {
        if frc.fetchedObjects == nil { try? frc.performFetch() }
    }

    func start() {
        try? frc.performFetch()
        output?.reloadData()

        let isEmpty = frc.fetchedObjects?.isEmpty ?? true
        let seeded = UserDefaults.standard.bool(forKey: seedFlagKey)
        if isEmpty && !seeded { seedFromNetwork() }
    }

    func edit(objectID: NSManagedObjectID) {
        guard (try? context.existingObject(with: objectID) as? ToDoRecord) != nil else { return }
        let child = CoreDataStack.shared.newChildContext()
        _ = child.object(with: objectID)
        output?.openDetails(objectID: objectID, in: child)
    }

    func delete(objectID: NSManagedObjectID) {
        context.perform { [weak self] in
            guard let self = self else { return }
            do {
                let obj = try self.context.existingObject(with: objectID)
                self.context.delete(obj)
                try CoreDataStack.shared.save(self.context)
            } catch {
                self.output?.failLoad(error)
            }
        }
    }


    func toggleDone(objectID: NSManagedObjectID) {
        context.perform { [weak self] in
            guard let self = self else { return }
            if let obj = try? self.context.existingObject(with: objectID) as? ToDoRecord {
                obj.completed.toggle()
                try? CoreDataStack.shared.save(self.context)
            }
        }
    }

    var numberOfRows: Int { ensureFetched(); return frc.fetchedObjects?.count ?? 0 }

    func model(at indexPath: IndexPath) -> ToDoRecord {
        ensureFetched()
        return frc.object(at: indexPath)
    }

    func addTapped() {
        let ctx = CoreDataStack.shared.newChildContext()
        let draft = ToDoRecord(context: ctx)
        draft.id = UUID()
        draft.completed = false
        draft.createdAt = Date()
        output?.openDetails(objectID: draft.objectID, in: ctx)
    }

    func fetchToDos() { seedFromNetwork(force: true) }

    private func seedFromNetwork(force: Bool = false) {
        service.fetchToDos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let dtos):
                do {
                    if force { try self.storage.clearAll() }
                    try self.storage.importTodos(dtos)
                    UserDefaults.standard.set(true, forKey: self.seedFlagKey)
                    DispatchQueue.main.async {
                        try? self.frc.performFetch()
                        self.output?.reloadData()
                    }
                } catch {
                    self.output?.failLoad(error)
                }
            case .failure(let error):
                self.output?.failLoad(error)
            }
        }
    }
}
