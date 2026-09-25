import UIKit

final class TrackersViewController: UIViewController {

    let viewModel: TrackersViewModel

    private var trackersCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(
            self,
            action: #selector(onDatePickerValueChanged(_:)),
            for: .valueChanged
        )
        return picker
    }()

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

    // MARK: - Init

    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setUpNavigationBar()
        setUpEmptyView()
        setUpCollectionView()
        setUpBindings()
        viewModel.viewDidLoad()
    }

    // MARK: - Bindings
    private func setUpBindings() {
        viewModel.onCategoriesChange = { [weak self] _ in
            guard let self else { return }
            self.trackersCollectionView.reloadData()
            self.updateEmptyState()
        }

        viewModel.onDateChange = { [weak self] date in
            guard let self, self.datePicker.date != date else { return }
            self.datePicker.setDate(date, animated: true)
        }

        viewModel.onSearchQueryChange = { [weak self] query in
            guard let self,
                self.searchController.searchBar.text != query
            else { return }
            self.searchController.searchBar.text = query
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    // MARK: - Setup

    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        emptyView.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
    }

    private func setUpCollectionView() {
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        view.addSubview(trackersCollectionView)
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            trackersCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            trackersCollectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            trackersCollectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
        ])
        trackersCollectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )
        trackersCollectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }

    private func setUpEmptyView() {
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
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
        let barButtonItem = UIBarButtonItem(customView: datePicker)
        if #available(iOS 26.0, *) {
            barButtonItem.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = barButtonItem
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func onTap() {
        presentTrackerForm(mode: .create)
    }

    func presentTrackerForm(mode: TrackerFormViewController.Mode) {
        let trackerFormController = TrackerFormViewController(mode: mode)
        trackerFormController.delegate = self
        let navigationController = UINavigationController(
            rootViewController: trackerFormController
        )
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc private func onDatePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.dateChanged(to: sender.date)
    }
}

// MARK: - TrackerFormViewControllerDelegate

extension TrackersViewController: TrackerFormViewControllerDelegate {
    func trackerFormViewController(
        _ controller: TrackerFormViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    ) {
        viewModel.addTracker(tracker, categoryTitle: categoryTitle)
    }

    func trackerFormViewController(
        _ controller: TrackerFormViewController,
        didUpdate tracker: Tracker,
        categoryTitle: String
    ) {
        viewModel.updateTracker(tracker, categoryTitle: categoryTitle)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapPlus(_ cell: TrackerCell) {
        guard let indexPath = trackersCollectionView.indexPath(for: cell)
        else { return }

        viewModel.toggleTracker(
            inSection: indexPath.section,
            at: indexPath.item
        )
    }
}
