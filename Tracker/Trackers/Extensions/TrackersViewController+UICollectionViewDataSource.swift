import UIKit

extension TrackersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.numberOfTrackers(in: section)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCell
        else {
            fatalError("Could not dequeue cell")
        }
        guard
            let model = viewModel.cellModel(
                inSection: indexPath.section,
                at: indexPath.item
            )
        else {
            return cell
        }

        cell.delegate = self
        cell.configure(with: model)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as? TrackerSectionHeaderView

        if let headerView {
            headerView.titleLabel.text = viewModel.sectionTitle(
                at: indexPath.section
            )
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
}
