import UIKit

final class CategoriesViewController: UIViewController {

    private let viewModel: CategoriesViewModel

    private let tableView = OptionsTableView()
    private let addButton = PrimaryButton(title: "Добавить категорию")
    private let emptyView = EmptyView(
        title: "Привычки и события можно\nобъединить по смыслу",
        imageName: AppImages.emptyViewImage
    )

    // MARK: - Init

    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Категория"
        view.backgroundColor = .whiteDay
        setUpAddButton()
        setUpEmptyView()
        setUpTableView()
        setUpBindings()
        viewModel.viewDidLoad()
    }

    // MARK: - Bindings

    private func setUpBindings() {
        viewModel.onCategoriesChange = { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadData()
            self.updateEmptyState()
        }

        viewModel.onSelectedCategoryChange = { [weak self] _ in
            self?.tableView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    // MARK: - Setup

    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        emptyView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .clear
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
            tableView.bottomAnchor.constraint(
                equalTo: addButton.topAnchor,
                constant: -16
            ),
        ])
    }

    private func setUpEmptyView() {
        view.addSubview(emptyView)
        emptyView.label.numberOfLines = 0
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setUpAddButton() {
        addButton.addTarget(
            self,
            action: #selector(onAddButtonTapped),
            for: .touchUpInside
        )

        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            addButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            addButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])
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

    @objc private func onAddButtonTapped() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.onDone = { [weak self] title in
            guard let self else { return }
            self.viewModel.addCategory(title: title)
            self.dismiss(animated: true)
        }

        let navigationController = UINavigationController(
            rootViewController: newCategoryViewController
        )
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.numberOfCategories
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        )

        guard let categoryCell = cell as? CategoryCell,
            let model = viewModel.cellModel(at: indexPath.row)
        else { return cell }

        categoryCell.configure(with: model)
        return categoryCell
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        viewModel.selectCategory(at: indexPath.row)
    }
}
