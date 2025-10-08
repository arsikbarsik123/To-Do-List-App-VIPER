import CoreData

protocol ToDoStorage {
    func fetchAll() throws -> [ToDoRecord]
    func create(title: String, note: String?) throws -> ToDoRecord
    func delete(_ object: ToDoRecord) throws
    func toggleDone(_ object: ToDoRecord) throws
    func importTodos(_ dtos: [ToDoDTO]) throws
    func clearAll() throws
}

final class ToDoStorageImpl: ToDoStorage {
    private let ctx: NSManagedObjectContext
    init(ctx: NSManagedObjectContext = CoreDataStack.shared.viewContext) { self.ctx = ctx }

    func fetchAll() throws -> [ToDoRecord] {
        let r: NSFetchRequest<ToDoRecord> = ToDoRecord.fetchRequest()
        r.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try ctx.fetch(r)
    }

    func create(title: String, note: String?) throws -> ToDoRecord {
        let obj = ToDoRecord(context: ctx)
        obj.id = UUID()
        obj.title = title
        obj.note = note
        obj.completed = false
        obj.createdAt = Date()
        try CoreDataStack.shared.save(ctx)
        return obj
    }

    func delete(_ object: ToDoRecord) throws {
        ctx.delete(object)
        try CoreDataStack.shared.save(ctx)
    }

    func toggleDone(_ object: ToDoRecord) throws {
        object.completed.toggle()
        try CoreDataStack.shared.save(ctx)
    }
    
    func importTodos(_ dtos: [ToDoDTO]) throws {
        let ctx = CoreDataStack.shared.newBackgroundContext()

        ctx.perform {
            let base = Date(timeIntervalSince1970: 1000000)
            
            for (idx, dto) in dtos.enumerated() {
                let obj = ToDoRecord(context: ctx)
                obj.id = UUID()
                obj.title = dto.todo
                obj.note = ""
                obj.completed = dto.completed
                obj.createdAt = Date()
                
                obj.createdAt = base.addingTimeInterval(TimeInterval(-idx))
            }

            do {
                try CoreDataStack.shared.save(ctx)
                print("Imported \(dtos.count) todos into CoreData")
            } catch {
                print("Import error: \(error)")
            }
        }
    }
    
    func clearAll() throws {
        let ctx = CoreDataStack.shared.newBackgroundContext()
        try ctx.performAndWait {
            let fetch: NSFetchRequest<NSFetchRequestResult> = ToDoRecord.fetchRequest()
            let req = NSBatchDeleteRequest(fetchRequest: fetch)
            req.resultType = .resultTypeObjectIDs
            let result = try ctx.execute(req) as? NSBatchDeleteResult

            if let ids = result?.result as? [NSManagedObjectID] {
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: ids]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes,
                                                    into: [CoreDataStack.shared.viewContext])
            }
            try CoreDataStack.shared.save(ctx)
        }
    }
}
