import UIKit

extension TrackerFormViewController {
    enum Mode {
        case create
        case edit(Tracker, categoryTitle: String, completedDays: Int)

        var title: String {
            switch self {
            case .create: "Новая привычка"
            case .edit: "Редактирование привычки"
            }
        }

        var actionTitle: String {
            switch self {
            case .create: "Создать"
            case .edit: "Сохранить"
            }
        }

        /// Новый id для создания, прежний — для редактирования.
        var trackerId: UUID {
            switch self {
            case .create: UUID()
            case .edit(let tracker, _, _): tracker.id
            }
        }

        var isPinned: Bool {
            switch self {
            case .create: false
            case .edit(let tracker, _, _): tracker.isPinned
            }
        }
    }

    func applyMode() {
        navigationItem.title = mode.title
        contentView.buttonsRow.createButton.setTitle(
            mode.actionTitle,
            for: .normal
        )

        guard case let .edit(tracker, categoryTitle, completedDays) = mode
        else { return }
        showDaysCounter(completedDays)
        prefill(with: tracker, categoryTitle: categoryTitle)
    }

    func notifyDelegate(with tracker: Tracker, categoryTitle: String) {
        switch mode {
        case .create:
            delegate?.trackerFormViewController(
                self,
                didCreate: tracker,
                categoryTitle: categoryTitle
            )
        case .edit:
            delegate?.trackerFormViewController(
                self,
                didUpdate: tracker,
                categoryTitle: categoryTitle
            )
        }
    }

    // MARK: - Private

    private func showDaysCounter(_ days: Int) {
        let label = contentView.daysCounterLabel
        label.isHidden = false
        label.text = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: ""),
            days
        )
        contentView.contentStack.setCustomSpacing(40, after: label)
    }

    private func prefill(with tracker: Tracker, categoryTitle: String) {
        trackerDraft = TrackerDraft(tracker: tracker, categoryTitle: categoryTitle)
        contentView.textField.text = tracker.name
        scheduleVC.selectedWeekDays = tracker.schedule

        if let index = emojis.firstIndex(of: tracker.emoji) {
            select(index, in: contentView.emojisCollectionView)
        }
        // Цвет из базы и цвет из ассетов — разные объекты UIColor, сравниваем по hex.
        let hex = tracker.color.hexString
        if let index = colors.firstIndex(where: { $0.hexString == hex }) {
            select(index, in: contentView.colorsCollectionView)
        }
    }

    private func select(_ index: Int, in collectionView: UICollectionView) {
        collectionView.selectItem(
            at: IndexPath(item: index, section: 0),
            animated: false,
            scrollPosition: []
        )
    }
}
