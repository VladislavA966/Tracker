import CoreData

/// Владеет долгоживущими зависимостями и собирает ViewModel'и.
/// Про экраны не знает — отсюда отсутствие `import UIKit`.
final class AppDependencies {

    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        trackerStore = TrackerStore(
            context: context,
            categoryStore: TrackerCategoryStore(context: context)
        )
        recordStore = TrackerRecordStore(context: context)
    }

    func makeTrackersViewModel() -> TrackersViewModel {
        TrackersViewModel(
            trackerStore: trackerStore,
            recordStore: recordStore
        )
    }
}
