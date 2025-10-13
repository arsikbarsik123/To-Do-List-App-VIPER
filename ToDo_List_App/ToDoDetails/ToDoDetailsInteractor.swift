import Foundation
import CoreData

protocol ToDoDetailsInteractorInput: AnyObject {
    func configure(objectID: NSManagedObjectID, editingContext: NSManagedObjectContext)
    func setTitle(_ text: String)
    func setNote(_ text: String)
    func setCompleted(_ flag: Bool)
    func commitChangesOnDisappear()
    func snapshot() -> (title: String, note: String, completed: Bool, createdAt: Date?)
}

final class ToDoDetailsInteractor: ToDoDetailsInteractorInput {
    func snapshot() -> (title: String, note: String, completed: Bool, createdAt: Date?) {
        let o = object
        return (o?.title ?? "",
                o?.note  ?? "",
                o?.completed ?? false,
                o?.createdAt)
    }

    private var ctx: NSManagedObjectContext!
    private var objectID: NSManagedObjectID!
    private var object: ToDoRecord? {
        (try? ctx.existingObject(with: objectID)) as? ToDoRecord
    }

    func configure(objectID: NSManagedObjectID, editingContext: NSManagedObjectContext) {
        self.objectID = objectID
        self.ctx = editingContext
    }

    func setTitle(_ text: String) { object?.title = text }
    
    func setNote(_ text: String) { object?.note = text }
    
    func setCompleted(_ flag: Bool) { object?.completed = flag }

    func commitChangesOnDisappear() {
        guard let obj = object else { return }
        
        let emptyTitle = (obj.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emptyNote = (obj.note ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if emptyTitle && emptyNote { ctx.delete(obj) }
        
        
        if obj.objectID.isTemporaryID {
            try? ctx.obtainPermanentIDs(for: [obj])
        }
        
        if ctx.hasChanges {
            try? CoreDataStack.shared.save(ctx)
        }
    }
}
