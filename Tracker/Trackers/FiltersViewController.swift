import UIKit

final class FiltersViewController: UIViewController {

    var onSelect: ((TrackerFilter) -> Void)?

    private let selectedFilter: TrackerFilter
    private let filters = TrackerFilter.allCases
    private let tableView = OptionsTableView()

    // MARK: - Init

    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Фильтры"
        view.backgroundColor = .whiteDay
        setUpTableView()
    }

    // MARK: - Setup

    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        tableView.register(
            CategoryCell.self,
            forCellReuseIdentifier: CategoryCell.reuseIdentifier
        )

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: AppConstants.optionRowHeight
                    * CGFloat(filters.count)
            ),
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        filters.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        )
        guard let filterCell = cell as? CategoryCell else { return cell }

        let filter = filters[indexPath.row]
        filterCell.configure(
            with: CategoryCellModel(
                title: filter.title,
                isSelected: filter.isActive && filter == selectedFilter
            )
        )

        if indexPath.row == filters.count - 1 {
            filterCell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        }
        return filterCell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        onSelect?(filters[indexPath.row])
    }
}
