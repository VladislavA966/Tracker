import UIKit

extension AddTrackerViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        collectionView === contentView.colorsCollectionView
            ? colors.count : emojis.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView === contentView.colorsCollectionView {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ColorCell.reuseIdentifier,
                    for: indexPath
                ) as? ColorCell
            else {
                fatalError("Unable to dequeue reusable cell")
            }
            cell.color = colors[indexPath.row]

            return cell
        }

        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCell
        else {
            fatalError("Unable to dequeue reusable cell")
        }
        cell.label.text = emojis[indexPath.row]

        return cell
    }
}

