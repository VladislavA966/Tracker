import Foundation

final class StatisticsViewModel {

    // MARK: - Bindings (ViewModel -> View)
    var onCompletedCountChange: Bind<Int>?

    // MARK: - State
    private(set) var completedCount = 0 {
        didSet { onCompletedCountChange?(completedCount) }
    }

    // MARK: - Dependencies
    private let recordStore: TrackerRecordStore

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
        recordStore.delegate = self
    }

    // MARK: - Derived state

    var isEmpty: Bool { completedCount == 0 }

    // MARK: - Intents (View -> ViewModel)

    func viewDidLoad() {
        recordStore.start()
        reload()
    }

    // MARK: - Private

    private func reload() {
        completedCount = recordStore.records.count
    }
}

// MARK: - TrackerRecordStoreDelegate

extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent(_ store: TrackerRecordStore) {
        reload()
    }
}
