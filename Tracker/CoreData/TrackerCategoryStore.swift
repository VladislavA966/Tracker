import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController:
        NSFetchedResultsController<TrackerCategoryCoreData> = {
            let request = TrackerCategoryCoreData.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "createdAt", ascending: true)
            ]

            let controller = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            controller.delegate = self
            return controller
        }()

    var titles: [String] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { $0.title }
    }

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        super.init()
    }

    func category(withTitle title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        if let existing = try context.fetch(request).first {
            return existing
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        category.createdAt = Date()
        return category
    }

    func start() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Не удалось загрузить категории: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.trackerCategoryStoreDidChangeContent(self)
    }
}
