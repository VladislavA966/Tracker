import UIKit

final class DatePickerViewController: UIViewController {

    var onDateSelected: ((Date) -> Void)?

    private let picker = UIDatePicker()

    init(date: Date) {
        super.init(nibName: nil, bundle: nil)
        picker.date = date
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.addTarget(
            self,
            action: #selector(onValueChanged),
            for: .valueChanged
        )

        view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.topAnchor),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        preferredContentSize = picker.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
    }

    @objc private func onValueChanged() {
        onDateSelected?(picker.date)
    }
}
