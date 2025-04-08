import UIKit

extension HomeView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        presenter.clearSearch()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.isSearching = !searchText.isEmpty
        presenter.filterTasks(for: searchText) {[weak self] filteredTasks in
            guard let self = self else { return }
            self.presenter.filteredTasks = filteredTasks
            self.tableView.reloadData()
        }
    }
}
