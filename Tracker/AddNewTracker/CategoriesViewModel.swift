import Foundation

final class CategoriesViewModel {

    // MARK: - Bindings (ViewModel -> View)
    var onCategoriesChange: Bind<[String]>?
    var onSelectedCategoryChange: Bind<String?>?
    var onError: Bind<String>?

    var onCategoryConfirmed: Bind<String>?

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
            selectedCategory = title
        } catch TrackerCategoryStoreError.emptyTitle {
            onError?("Название категории не может быть пустым")
        } catch TrackerCategoryStoreError.duplicateTitle {
            onError?("Такая категория уже есть")
        } catch {
            onError?("Не удалось сохранить категорию")
        }
    }

    // MARK: - Private

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
