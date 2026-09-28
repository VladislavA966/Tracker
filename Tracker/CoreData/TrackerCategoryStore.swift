import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore)
}

enum TrackerCategoryStoreError: Error {
    case emptyTitle
    case duplicateTitle
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
        if let existing = try existingCategory(withTitle: title) {
            return existing
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        category.createdAt = Date()
        return category
    }

    func addCategory(title: String) throws {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw TrackerCategoryStoreError.emptyTitle
        }
        guard try !titleExists(title) else {
            throw TrackerCategoryStoreError.duplicateTitle
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        category.createdAt = Date()
        try save()
    }

    func renameCategory(from oldTitle: String, to newTitle: String) throws {
        let newTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newTitle.isEmpty else {
            throw TrackerCategoryStoreError.emptyTitle
        }
        let isSameTitle =
            newTitle.caseInsensitiveCompare(oldTitle) == .orderedSame
        guard try isSameTitle || !titleExists(newTitle) else {
            throw TrackerCategoryStoreError.duplicateTitle
        }
        guard let category = try existingCategory(withTitle: oldTitle) else {
            return
        }

        category.title = newTitle
        try save()
    }

    func deleteCategory(withTitle title: String) throws {
        guard let category = try existingCategory(withTitle: title) else {
            return
        }
        context.delete(category)
        try save()
    }

    func titleExists(_ title: String) throws -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title ==[cd] %@", title)
        request.fetchLimit = 1
        return try context.count(for: request) > 0
    }

    private func existingCategory(
        withTitle title: String
    ) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func save() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
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
