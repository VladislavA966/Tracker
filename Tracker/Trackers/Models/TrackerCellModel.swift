import Foundation

/// Всё, что нужно ячейке для отрисовки. Собирается во ViewModel,
/// чтобы dataSource не считал ничего сам.
struct TrackerCellModel {
    let tracker: Tracker
    let isCompleted: Bool
    let completedDays: Int
    let isPlusEnabled: Bool
}
