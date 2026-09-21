import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChangeContent(_ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController:
        NSFetchedResultsController<TrackerRecordCoreData> = {
            let request = TrackerRecordCoreData.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "date", ascending: true)
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

    private var entities: [TrackerRecordCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    var records: [TrackerRecord] {
        entities.compactMap { entity in
            guard let trackerId = entity.trackerId, let date = entity.date
            else { return nil }

            return TrackerRecord(trackerId: trackerId, completedDate: date)
        }
    }

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        super.init()
    }

    func completedTrackerIds(on date: Date) -> Set<UUID> {
        let day = Calendar.current.startOfDay(for: date)
        return Set(
            records
                .filter {
                    Calendar.current.isDate($0.completedDate, inSameDayAs: day)
                }
                .map { $0.trackerId }
        )
    }

    func completedDays(for trackerId: UUID) -> Int {
        records.filter { $0.trackerId == trackerId }.count
    }

    func toggle(trackerId: UUID, on date: Date) throws {
        let day = Calendar.current.startOfDay(for: date)

        if let existing = entities.first(where: {
            $0.trackerId == trackerId
                && $0.date.map {
                    Calendar.current.isDate($0, inSameDayAs: day)
                } ?? false
        }) {
            context.delete(existing)
        } else {
            let record = TrackerRecordCoreData(context: context)
            record.trackerId = trackerId
            record.date = day
            record.tracker = try tracker(withId: trackerId)
        }

        try CoreDataStack.shared.saveContext()
    }

    private func tracker(withId id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    func start() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Не удалось загрузить отметки: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.trackerRecordStoreDidChangeContent(self)
    }
}
