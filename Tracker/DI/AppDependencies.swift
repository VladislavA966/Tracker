import CoreData

final class AppDependencies {

    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    private let onboardingStorage: OnboardingStorage

    var hasSeenOnboarding: Bool {
        get { onboardingStorage.hasSeenOnboarding }
        set { onboardingStorage.hasSeenOnboarding = newValue }
    }

    init(
        context: NSManagedObjectContext = CoreDataStack.shared.viewContext,
        onboardingStorage: OnboardingStorage = OnboardingStorage()
    ) {
        trackerStore = TrackerStore(
            context: context,
            categoryStore: TrackerCategoryStore(context: context)
        )
        recordStore = TrackerRecordStore(context: context)
        self.onboardingStorage = onboardingStorage
    }

    func makeTrackersViewModel() -> TrackersViewModel {
        TrackersViewModel(
            trackerStore: trackerStore,
            recordStore: recordStore
        )
    }
}
