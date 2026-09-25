import UIKit

extension AddTrackerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Option.allCases[indexPath.row] {
        case .category: selectCategory()
        case .schedule: selectSchedule()
        }
    }

    private func selectCategory() {
        let viewModel = CategoriesViewModel(
            selectedCategory: trackerDraft.category
        )
        viewModel.onCategoryConfirmed = { [weak self] title in
            guard let self else { return }
            self.trackerDraft.category = title
            self.reloadOption(.category)
            self.dismiss(animated: true)
        }

        present(
            UINavigationController(
                rootViewController: CategoriesViewController(
                    viewModel: viewModel
                )
            ),
            animated: true
        )
    }

    private func selectSchedule() {
        present(
            UINavigationController(rootViewController: scheduleVC),
            animated: true
        )
    }
}
