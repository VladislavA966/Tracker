import UIKit

extension TrackersViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
            let tracker = viewModel.tracker(
                inSection: indexPath.section,
                at: indexPath.item
            )
        else { return nil }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { [weak self] _ in
            let pin = UIAction(
                title: tracker.isPinned ? "Открепить" : "Закрепить"
            ) { _ in
                self?.viewModel.setPinned(
                    !tracker.isPinned,
                    forTrackerWithId: tracker.id
                )
            }
            let edit = UIAction(title: "Редактировать") { _ in
                self?.presentEditForm(for: tracker)
            }
            let delete = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { _ in
                self?.confirmDeletion(of: tracker)
            }
            return UIMenu(children: [pin, edit, delete])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        cardPreview(in: collectionView, at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        cardPreview(in: collectionView, at: indexPath)
    }

    // MARK: - Private

    private func cardPreview(
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell
        else { return nil }

        let card = cell.previewView
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: card.bounds,
            cornerRadius: card.layer.cornerRadius
        )
        return UITargetedPreview(view: card, parameters: parameters)
    }

    private func presentEditForm(for tracker: Tracker) {
        guard
            let categoryTitle = viewModel.categoryTitle(
                forTrackerWithId: tracker.id
            )
        else { return }

        presentTrackerForm(
            mode: .edit(
                tracker,
                categoryTitle: categoryTitle,
                completedDays: viewModel.completedDays(
                    forTrackerWithId: tracker.id
                )
            )
        )
    }

    private func confirmDeletion(of tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: "Удалить", style: .destructive) {
                [weak self] _ in
                self?.viewModel.deleteTracker(withId: tracker.id)
            }
        )
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(alert, animated: true)
    }
}
