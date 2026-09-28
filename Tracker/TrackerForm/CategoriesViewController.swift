import UIKit

final class CategoriesViewController: UIViewController {

    private let viewModel: CategoriesViewModel

    private let tableView = OptionsTableView()
    private let addButton = PrimaryButton(title: String(localized: .categoriesAdd))
    private let emptyView = EmptyView(
        title: String(localized: .categoriesEmpty),
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
        navigationItem.title = String(localized: .categoriesTitle)
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
        alert.addAction(UIAlertAction(title: String(localized: .commonOk), style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func onAddButtonTapped() {
        presentCategoryForm(mode: .create) { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
    }

    private func presentCategoryForm(
        mode: CategoryFormViewController.Mode,
        onDone: @escaping (String) -> Void
    ) {
        let categoryFormController = CategoryFormViewController(mode: mode)
        categoryFormController.onDone = { [weak self] title in
            onDone(title)
            self?.dismiss(animated: true)
        }

        let navigationController = UINavigationController(
            rootViewController: categoryFormController
        )
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    fileprivate func editCategory(_ title: String) {
        presentCategoryForm(mode: .edit(title: title)) { [weak self] newTitle in
            self?.viewModel.renameCategory(from: title, to: newTitle)
        }
    }

    fileprivate func confirmDeletion(of title: String) {
        let alert = UIAlertController(
            title: nil,
            message: String(localized: .categoriesDeleteAlertMessage),
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: .commonDelete),
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.deleteCategory(withTitle: title)
            }
        )
        alert.addAction(
            UIAlertAction(title: String(localized: .commonCancel), style: .cancel)
        )
        present(alert, animated: true)
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

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let title = viewModel.title(at: indexPath.row) else { return nil }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { [weak self] _ in
            let edit = UIAction(title: String(localized: .commonEdit)) { _ in
                self?.editCategory(title)
            }
            let delete = UIAction(
                title: String(localized: .commonDelete),
                attributes: .destructive
            ) { _ in
                self?.confirmDeletion(of: title)
            }
            return UIMenu(children: [edit, delete])
        }
    }
}
