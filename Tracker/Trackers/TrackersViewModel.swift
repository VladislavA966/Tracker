import Foundation


typealias Bind<T> = (T) -> Void

final class TrackersViewModel {

    // MARK: - Bindings (ViewModel -> View)
    var onCategoriesChange: Bind<[TrackerCategory]>?
    var onDateChange: Bind<Date>?
    var onSearchQueryChange: Bind<String>?
    var onError: Bind<String>?

    // MARK: - State
    private(set) var visibleCategories: [TrackerCategory] = [] {
        didSet { onCategoriesChange?(visibleCategories) }
    }

    private(set) var currentDate: Date = Date() {
        didSet { onDateChange?(currentDate) }
    }

    private(set) var searchQuery: String = "" {
        didSet { onSearchQueryChange?(searchQuery) }
    }

    private var completedIds: Set<UUID> = []

    private static let pinnedCategoryTitle = "Закреплённые"

    // MARK: - Dependencies
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    init(
        trackerStore: TrackerStore = TrackerStore(),
        recordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        trackerStore.delegate = self
        recordStore.delegate = self
    }

    // MARK: - Derived state

    var isEmpty: Bool { visibleCategories.isEmpty }

    var numberOfSections: Int { visibleCategories.count }

    var isPlusEnabled: Bool { !isCurrentDateInFuture }

    private var isCurrentDateInFuture: Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: currentDate)
            > calendar.startOfDay(for: Date())
    }

    private var categories: [TrackerCategory] { trackerStore.categories }

    // MARK: - Data source

    func numberOfTrackers(in section: Int) -> Int {
        guard visibleCategories.indices.contains(section) else { return 0 }
        return visibleCategories[section].trackers.count
    }

    func sectionTitle(at section: Int) -> String? {
        guard visibleCategories.indices.contains(section) else { return nil }
        return visibleCategories[section].headerTitle
    }

    func tracker(inSection section: Int, at index: Int) -> Tracker? {
        guard visibleCategories.indices.contains(section) else { return nil }
        let trackers = visibleCategories[section].trackers
        guard trackers.indices.contains(index) else { return nil }
        return trackers[index]
    }

    func cellModel(inSection section: Int, at index: Int) -> TrackerCellModel? {
        guard let tracker = tracker(inSection: section, at: index) else {
            return nil
        }
        return TrackerCellModel(
            tracker: tracker,
            isCompleted: completedIds.contains(tracker.id),
            completedDays: completedDays(forTrackerWithId: tracker.id),
            isPlusEnabled: isPlusEnabled
        )
    }

    func categoryTitle(forTrackerWithId id: UUID) -> String? {
        categories.first { category in
            category.trackers.contains { $0.id == id }
        }?.headerTitle
    }

    func completedDays(forTrackerWithId id: UUID) -> Int {
        recordStore.completedDays(for: id)
    }

    // MARK: - Intents (View -> ViewModel)

    func viewDidLoad() {
        trackerStore.start()
        recordStore.start()
        reload()
    }

    func dateChanged(to date: Date) {
        guard currentDate != date else { return }
        currentDate = date
        reload()
    }

    func search(query: String) {
        guard searchQuery != query else { return }
        searchQuery = query
        reload()
    }

    func toggleTracker(inSection section: Int, at index: Int) {
        guard isPlusEnabled,
            let tracker = tracker(inSection: section, at: index)
        else { return }

        do {
            try recordStore.toggle(trackerId: tracker.id, on: currentDate)
        } catch {
            onError?("Не удалось изменить отметку")
        }
    }

    func setPinned(_ isPinned: Bool, forTrackerWithId id: UUID) {
        do {
            try trackerStore.setPinned(isPinned, forTrackerWithId: id)
        } catch {
            onError?("Не удалось закрепить трекер")
        }
    }

    func deleteTracker(withId id: UUID) {
        do {
            try trackerStore.deleteTracker(withId: id)
        } catch {
            onError?("Не удалось удалить трекер")
        }
    }

    func updateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            onError?("Не удалось сохранить изменения")
        }
    }

    func addTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            onError?("Не удалось сохранить трекер")
            return
        }

        searchQuery = ""
        focusDate(for: tracker)
        reload()
    }

    // MARK: - Private

    private func reload() {
        completedIds = recordStore.completedTrackerIds(on: currentDate)
        visibleCategories = makeVisibleCategories()
    }

    private func makeVisibleCategories() -> [TrackerCategory] {
        guard let weekDay = WeekDay(date: currentDate) else { return [] }
        let query =
            searchQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let isVisible: (Tracker) -> Bool = { tracker in
            let matchesDay =
                tracker.schedule.isEmpty || tracker.schedule.contains(weekDay)
            let matchesQuery =
                query.isEmpty || tracker.name.lowercased().contains(query)
            return matchesDay && matchesQuery
        }

        let pinned = categories
            .flatMap(\.trackers)
            .filter { $0.isPinned && isVisible($0) }
        let pinnedSection = TrackerCategory(
            headerTitle: Self.pinnedCategoryTitle,
            trackers: pinned
        )

        let regularSections = categories.map { category in
            TrackerCategory(
                headerTitle: category.headerTitle,
                trackers: category.trackers.filter {
                    !$0.isPinned && isVisible($0)
                }
            )
        }

        return ([pinnedSection] + regularSections).filter {
            !$0.trackers.isEmpty
        }
    }


    private func focusDate(for tracker: Tracker) {
        guard !tracker.schedule.isEmpty else { return }
        if let today = WeekDay(date: currentDate),
            tracker.schedule.contains(today)
        {
            return
        }

        let calendar = Calendar.current
        for offset in 1...WeekDay.allCases.count {
            guard
                let candidate = calendar.date(
                    byAdding: .day,
                    value: offset,
                    to: currentDate
                ),
                let day = WeekDay(date: candidate),
                tracker.schedule.contains(day)
            else { continue }

            currentDate = candidate
            return
        }
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewModel: TrackerStoreDelegate {
    func trackerStoreDidChangeContent(_ store: TrackerStore) {
        reload()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent(_ store: TrackerRecordStore) {
        reload()
    }
}
