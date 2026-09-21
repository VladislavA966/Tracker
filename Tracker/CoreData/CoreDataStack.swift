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
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            throw error
        }
    }
}
