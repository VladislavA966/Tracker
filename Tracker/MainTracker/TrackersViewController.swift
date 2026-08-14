import UIKit

final class TrackersViewController: UIViewController {
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

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
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекер"
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
        let datePicker = UIDatePicker()

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        let barButtonItem = UIBarButtonItem(customView: datePicker)
        if #available(iOS 26.0, *) {
            barButtonItem.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = barButtonItem

        datePicker.addTarget(
            self,
            action: #selector(onDatePickerValueChanged(_:)),
            for: .valueChanged
        )
    }

    @objc private func onTap() {
        let addNewHabitController = AddTrackerViewController()
        let navigationController = UINavigationController(
            rootViewController: addNewHabitController
        )
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc private func onDatePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        navigationItem.rightBarButtonItem?.title = dateFormatter.string(
            from: selectedDate
        )
    }
}
