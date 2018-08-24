//
//  MasterViewController.swift
//  English - Turkish Dictionary
//
//  Created by quoccuong on 8/1/18.
//  Copyright © 2018 quoccuong. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var detailViewController: DetailViewController? = nil
    var wordsPackage    = [Word]()
    var filteredWords   = [Word]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isSearchTextEmpty = true {
        didSet {
            let label = "Pull up to search and see scopes"
            DispatchQueue.main.async {
                self.tableView.backgroundView = self.isSearchTextEmpty ? self.createLabel(label: label) : nil
            }
        }
    }
    
    var noResultIsReal = false {
        didSet {
            let label = "Nothing to show."
            tableView.backgroundView = noResultIsReal ? createLabel(label: label) : nil
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        isSearchTextEmpty = true
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    

    }
    
    func openDatabase() {
        let url = SQLiteHelper.shared.url
        let _ = SQLiteHelper.shared.openDatabase(filePath: url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if splitViewController!.isCollapsed {
            if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
            }
        }
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let wordData: Word
                wordData = filteredWords[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailWord = wordData
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    func loadMoreData(lastValue: Int32, scope: String = "All") {
        let searchText = searchController.searchBar.text!
        
        openDatabase()
        SQLiteHelper.shared.query(matchWord: searchText, lastValue: lastValue)
        
        let comingPackage = SQLiteHelper.shared.wordsPackage
        
        let packageToBeAdded = comingPackage.filter({ (wordData : Word) -> Bool in
            let doesCategoryMatch = (scope == "All") || (wordData.category == scope)
            return doesCategoryMatch
        })
        filteredWords.append(contentsOf: packageToBeAdded)
        tableView.reloadData()
    }
    
    func createLabel(label: String) -> UILabel {
        let labelToBeCreated: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        labelToBeCreated.text          = label
        labelToBeCreated.textColor     = UIColor.black
        labelToBeCreated.textAlignment = .center
        tableView.separatorStyle  = .none
        return labelToBeCreated
    }
}

extension MasterViewController: UITableViewDataSource {

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let packageIsEmpty = SQLiteHelper.shared.wordsPackage.count < 1
        let searchTextIsEmpty = isFiltering() && searchBarIsEmpty()
        
        if packageIsEmpty || searchTextIsEmpty {
            noResultIsReal = true
        } else { noResultIsReal = false }
        
        
        return filteredWords.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let wordData = filteredWords[indexPath.row]
        
        cell.textLabel!.text = wordData.word
        cell.detailTextLabel?.text = wordData.definitionString
        
        let lastValue = filteredWords.count - 1
        let totalItems = SQLiteHelper.shared.wordsPackage.count
      
        //Reach the last row.
        if indexPath.row == lastValue {
            if totalItems > filteredWords.count {
            let searchBar = searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            let lastItemIndex = Int32(filteredWords[indexPath.row].index)
            loadMoreData(lastValue: lastItemIndex, scope: scope)
            }
        }
        return cell
    }
}

extension MasterViewController: UISearchResultsUpdating {
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search any words.."
        navigationItem.searchController = searchController
        searchController.searchBar.scopeButtonTitles = ["All","English","Turkish"]
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
            if !searchBarIsEmpty() {
                openDatabase()
                SQLiteHelper.shared.query(matchWord: searchText, lastValue: 0)
                filteredWords = []
                wordsPackage = SQLiteHelper.shared.wordsPackage
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.filteredWords = searchText.isEmpty ? (self.wordsPackage) : self.wordsPackage.filter({ (wordData : Word) -> Bool in
                        let doesCategoryMatch = (scope == "All") || (wordData.category == scope)
                        return doesCategoryMatch && wordData.word.lowercased().contains(searchText.lowercased())
                    })
                })
            } else {
                filteredWords = []
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension MasterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
