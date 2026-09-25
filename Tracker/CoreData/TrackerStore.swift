import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChangeContent(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore

    private lazy var fetchedResultsController:
        NSFetchedResultsController<TrackerCoreData> = {
            let request = TrackerCoreData.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "category.createdAt", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: true),
            ]

            let controller = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "category.title",
                cacheName: nil
            )
            controller.delegate = self
            return controller
        }()

    var categories: [TrackerCategory] {
        (fetchedResultsController.sections ?? []).compactMap { section in
            let entities = section.objects as? [TrackerCoreData] ?? []
            let trackers = entities.compactMap(tracker(from:))
            guard !trackers.isEmpty else { return nil }

            return TrackerCategory(
                headerTitle: section.name,
                trackers: trackers
            )
        }
    }

    init(
        context: NSManagedObjectContext = CoreDataStack.shared.viewContext,
        categoryStore: TrackerCategoryStore = TrackerCategoryStore()
    ) {
        self.context = context
        self.categoryStore = categoryStore
        super.init()
    }

    func addTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.createdAt = Date()
        try fill(entity, with: tracker, categoryTitle: categoryTitle)

        try CoreDataStack.shared.saveContext()
    }

    func updateTracker(_ tracker: Tracker, categoryTitle: String) throws {
        guard let entity = try entity(withId: tracker.id) else { return }
        try fill(entity, with: tracker, categoryTitle: categoryTitle)

        try CoreDataStack.shared.saveContext()
    }

    func deleteTracker(withId id: UUID) throws {
        guard let entity = try entity(withId: id) else { return }
        context.delete(entity)
        try CoreDataStack.shared.saveContext()
    }

    private func fill(
        _ entity: TrackerCoreData,
        with tracker: Tracker,
        categoryTitle: String
    ) throws {
        entity.name = tracker.name
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.hexString
        entity.schedule = encode(tracker.schedule)
        entity.category = try categoryStore.category(withTitle: categoryTitle)
    }

    private func entity(withId id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func tracker(from entity: TrackerCoreData) -> Tracker? {
        guard
            let id = entity.id,
            let name = entity.name,
            let emoji = entity.emoji,
            let colorHex = entity.colorHex,
            let color = UIColor(hexString: colorHex)
        else {
            return nil
        }

        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: decode(entity.schedule)
        )
    }

    private func encode(_ schedule: Set<WeekDay>) -> String {
        WeekDay.allCases
            .filter { schedule.contains($0) }
            .map { String($0.calendarWeekday) }
            .joined(separator: ",")
    }

    private func decode(_ schedule: String?) -> Set<WeekDay> {
        guard let schedule, !schedule.isEmpty else { return [] }

        let weekdays = schedule.split(separator: ",").compactMap { Int($0) }
        return Set(
            WeekDay.allCases.filter { weekdays.contains($0.calendarWeekday) }
        )
    }

    func start() {
        categoryStore.start()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Не удалось загрузить трекеры: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.trackerStoreDidChangeContent(self)
    }
}
