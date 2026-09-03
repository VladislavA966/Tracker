import UIKit

final class SelfSizingCollectionView: UICollectionView {

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return collectionViewLayout.collectionViewContentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }

}
