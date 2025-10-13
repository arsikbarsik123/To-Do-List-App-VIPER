import CoreData

protocol ToDoStorage {
    func fetchAll() throws -> [ToDoRecord]
    func create(title: String, note: String?) throws -> ToDoRecord
    func delete(_ object: ToDoRecord) throws
    func toggleDone(_ object: ToDoRecord) throws
    func importTodos(_ dtos: [ToDoDTO]) throws
    func clearAll() throws
}

final class ToDoStorageImpl {
    private let ctx: NSManagedObjectContext
    init(ctx: NSManagedObjectContext = CoreDataStack.shared.viewContext) { self.ctx = ctx }
}

extension ToDoStorageImpl: ToDoStorage {
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

        try ctx.performAndWait {
            let base = Date().addingTimeInterval(-3600)
            
            for (idx, dto) in dtos.enumerated() {
                let fr: NSFetchRequest<ToDoRecord> = ToDoRecord.fetchRequest()
                fr.fetchLimit = 1
                fr.predicate = NSPredicate(format: "remoteID == %d", dto.id)
                
                if (try ctx.fetch(fr).first) != nil {
                    continue
                }
    
                let obj = ToDoRecord(context: ctx)
                obj.id = UUID()
                obj.title = dto.todo
                obj.remoteID = Int64(dto.id)
                obj.note = ""
                obj.completed = dto.completed
                obj.createdAt = base.addingTimeInterval(TimeInterval(-idx))
            }

            try CoreDataStack.shared.save(ctx)
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
