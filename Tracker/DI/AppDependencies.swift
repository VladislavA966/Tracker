import CoreData

final class AppDependencies {

    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    private let categoryStore: TrackerCategoryStore
    private let onboardingStorage: OnboardingStorage

    var hasSeenOnboarding: Bool {
        get { onboardingStorage.hasSeenOnboarding }
        set { onboardingStorage.hasSeenOnboarding = newValue }
    }

    init(
        context: NSManagedObjectContext = CoreDataStack.shared.viewContext,
        onboardingStorage: OnboardingStorage = OnboardingStorage()
    ) {
        categoryStore = TrackerCategoryStore(context: context)
        trackerStore = TrackerStore(
            context: context,
            categoryStore: categoryStore
        )
        recordStore = TrackerRecordStore(context: context)
        self.onboardingStorage = onboardingStorage
    }

    func makeCategoriesViewModel(
        selectedCategory: String? = nil
    ) -> CategoriesViewModel {
        CategoriesViewModel(
            categoryStore: categoryStore,
            selectedCategory: selectedCategory
        )
    }

    func makeTrackersViewModel() -> TrackersViewModel {
        TrackersViewModel(
            trackerStore: trackerStore,
            recordStore: recordStore
        )
    }
}
