import Foundation

final class CategoriesViewModel {

    // MARK: - Bindings (ViewModel -> View)
    var onCategoriesChange: Bind<[String]>?
    var onSelectedCategoryChange: Bind<String?>?
    var onError: Bind<String>?

    var onCategoryConfirmed: Bind<String>?
    var onSelectedCategoryUpdate: Bind<String?>?

    // MARK: - State
    private(set) var categories: [String] = [] {
        didSet { onCategoriesChange?(categories) }
    }

    private(set) var selectedCategory: String? {
        didSet { onSelectedCategoryChange?(selectedCategory) }
    }

    // MARK: - Dependencies
    private let categoryStore: TrackerCategoryStore

    init(
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        selectedCategory: String? = nil
    ) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
        categoryStore.delegate = self
    }

    // MARK: - Derived state

    var isEmpty: Bool { categories.isEmpty }

    var numberOfCategories: Int { categories.count }

    // MARK: - Data source

    func title(at index: Int) -> String? {
        guard categories.indices.contains(index) else { return nil }
        return categories[index]
    }

    func cellModel(at index: Int) -> CategoryCellModel? {
        guard let title = title(at: index) else { return nil }
        return CategoryCellModel(
            title: title,
            isSelected: title == selectedCategory
        )
    }

    // MARK: - Intents (View -> ViewModel)

    func viewDidLoad() {
        categoryStore.start()
        reload()
    }

    func selectCategory(at index: Int) {
        guard let title = title(at: index) else { return }
        selectedCategory = title
        onCategoryConfirmed?(title)
    }

    func addCategory(title: String) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try categoryStore.addCategory(title: title)
        } catch {
            onError?(message(for: error))
        }
    }

    func renameCategory(from oldTitle: String, to newTitle: String) {
        let newTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try categoryStore.renameCategory(from: oldTitle, to: newTitle)
        } catch {
            onError?(message(for: error))
            return
        }

        guard selectedCategory == oldTitle else { return }
        selectedCategory = newTitle
        onSelectedCategoryUpdate?(newTitle)
    }

    func deleteCategory(withTitle title: String) {
        do {
            try categoryStore.deleteCategory(withTitle: title)
        } catch {
            onError?(String(localized: .categoriesErrorDelete))
            return
        }

        guard selectedCategory == title else { return }
        selectedCategory = nil
        onSelectedCategoryUpdate?(nil)
    }

    // MARK: - Private

    private func message(for error: Error) -> String {
        switch error {
        case TrackerCategoryStoreError.emptyTitle:
            String(localized: .categoriesErrorEmpty)
        case TrackerCategoryStoreError.duplicateTitle:
            String(localized: .categoriesErrorDuplicate)
        default:
            String(localized: .categoriesErrorSave)
        }
    }

    private func reload() {
        categories = categoryStore.titles
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore) {
        reload()
    }
}
