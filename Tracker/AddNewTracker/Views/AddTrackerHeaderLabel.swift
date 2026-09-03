import UIKit


final class AddTrackerHeaderLabel: UILabel {
    init(frame: CGRect, title: String? = nil) {
        super.init(frame: frame)
        font = .ypBold19
        text = title
    }


    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }

 
}
