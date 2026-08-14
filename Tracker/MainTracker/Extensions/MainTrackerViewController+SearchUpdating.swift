import UIKit

extension MainTrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        _ = searchController.searchBar.text ?? ""
        //        filterTrackers(by: query)
    }
}
