import UIKit

final class TrackersViewController: UIViewController {
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    var filteredCategories: [TrackerCategory] = []
    private var completedIdsForCurrentDate: Set<UUID> = []
    private var currentDate: Date = Date()
    private var searchQuery: String = ""
    private var trackersCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(
            self,
            action: #selector(onDatePickerValueChanged(_:)),
            for: .valueChanged
        )
        return picker
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Поиск"
        return controller
    }()

    private let emptyView = EmptyView(
        title: "Что будем отслеживать?",
        imageName: AppImages.emptyViewImage
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setUpNavigationBar()
        setUpEmptyView()
        setUpCollectionView()
        setUpStores()
        reloadData()
    }

    // MARK: - Setup

    private func setUpStores() {
        trackerStore.delegate = self
        recordStore.delegate = self
        trackerStore.start()
        recordStore.start()
    }

    // MARK: - State

    var categories: [TrackerCategory] {
        trackerStore.categories
    }

    func reloadData() {
        filteredCategories = makeVisibleCategories()
        completedIdsForCurrentDate = recordStore.completedTrackerIds(
            on: currentDate
        )
        trackersCollectionView.reloadData()
        updateEmptyState()
    }

    private func makeVisibleCategories() -> [TrackerCategory] {
        guard let weekDay = WeekDay(date: currentDate) else { return [] }
        let query =
            searchQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesDay =
                    tracker.schedule.isEmpty
                    || tracker.schedule.contains(weekDay)
                let matchesQuery =
                    query.isEmpty || tracker.name.lowercased().contains(query)
                return matchesDay && matchesQuery
            }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(
                headerTitle: category.headerTitle,
                trackers: trackers
            )
        }
    }

    func isCompleted(_ trackerId: UUID) -> Bool {
        completedIdsForCurrentDate.contains(trackerId)
    }

    func completedDays(for trackerId: UUID) -> Int {
        recordStore.completedDays(for: trackerId)
    }

    var isCurrentDateInFuture: Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: currentDate)
            > calendar.startOfDay(for: Date())
    }

    func search(query: String) {
        searchQuery = query
        reloadData()
    }

    private func updateEmptyState() {
        let isEmpty = filteredCategories.isEmpty
        emptyView.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
    }

    private func setUpCollectionView() {
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        view.addSubview(trackersCollectionView)
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            trackersCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            trackersCollectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            trackersCollectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
        ])
        trackersCollectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )
        trackersCollectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }

    private func setUpEmptyView() {
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let addButton = UIBarButtonItem(
            image: UIImage(named: AppImages.addIcon),
            style: .plain,
            target: self,
            action: #selector(onTap)
        )
        navigationItem.leftBarButtonItem = addButton
        let barButtonItem = UIBarButtonItem(customView: datePicker)
        if #available(iOS 26.0, *) {
            barButtonItem.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = barButtonItem
    }

    @objc private func onTap() {
        let addNewHabitController = AddTrackerViewController()
        addNewHabitController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: addNewHabitController
        )
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc private func onDatePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadData()
    }
}

// MARK: - AddTrackerViewControllerDelegate

extension TrackersViewController: AddTrackerViewControllerDelegate {
    func addTrackerViewController(
        _ controller: AddTrackerViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    ) {
        do {
            try trackerStore.addTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            assertionFailure("Не удалось сохранить трекер: \(error)")
            return
        }

        clearSearch()
        focusDate(for: tracker)
        reloadData()
    }

    private func clearSearch() {
        searchQuery = ""
        if searchController.isActive {
            searchController.searchBar.text = ""
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
            datePicker.setDate(candidate, animated: true)
            return
        }
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapPlus(_ cell: TrackerCell) {
        guard !isCurrentDateInFuture,
            let indexPath = trackersCollectionView.indexPath(for: cell)
        else { return }

        let tracker = filteredCategories[indexPath.section].trackers[
            indexPath.item
        ]

        do {
            try recordStore.toggle(trackerId: tracker.id, on: currentDate)
        } catch {
            assertionFailure("Не удалось изменить отметку: \(error)")
        }
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidChangeContent(_ store: TrackerStore) {
        reloadData()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent(_ store: TrackerRecordStore) {
        reloadData()
    }
}
