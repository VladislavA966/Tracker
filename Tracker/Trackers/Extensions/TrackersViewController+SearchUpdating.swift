import UIKit

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        search(query: searchController.searchBar.text ?? "")
    }
}
