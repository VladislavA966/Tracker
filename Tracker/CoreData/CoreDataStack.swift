import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "TrackerDataModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Не удалось загрузить хранилище: \(error)")
            }
        }
        persistentContainer.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
    }

    func saveContext() throws {
        try viewContext.saveIfNeeded()
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            rollback()
            throw error
        }
    }
}
