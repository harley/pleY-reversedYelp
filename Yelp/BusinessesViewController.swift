//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

    var businesses: [Business]!
//    var businessCollection: [BusinessCollection]!
    var scopedBusinesses: [Business]?
    
    @IBOutlet weak var tableView: UITableView!

    var searchBar: UISearchBar!
    var isSearching: Bool = false
    var currentFilters = [String : AnyObject]()

    var offset: Int = 0
    var limit: Int = 20
    var total: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        currentFilters["term"] = "Coffee"
        currentFilters["sort"] = YelpSortMode.Distance.rawValue
        currentFilters["categories"] = ["asianfusion", "burgers"]
        currentFilters["deals"] = false
        currentFilters["offset"] = offset
        currentFilters["limit"] = limit

        loadBusinesses(currentFilters)

        searchBar = UISearchBar()
        searchBar.text = currentFilters["term"] as! String
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self

        // change indicator view style to white
        tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyle.Gray

        // Add infinite scroll handler
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            let tableView = scrollView as! UITableView

            //
            // fetch your data here, can be async operation,
            // just make sure to call finishInfiniteScroll in the end
            //
            self.loadBusinessesWhileScrolling(self.currentFilters)
        }
    }

    func loadBusinesses(filters: [String:AnyObject]) {
        println("loading \(filters)")
        var categories = filters["categories"] as? [String]
        var deals = filters["deals"] as? Bool
        var sort:YelpSortMode?
        if filters["sort"] != nil {
            sort = YelpSortMode(rawValue: filters["sort"] as! Int)
        } else {
            sort = nil
        }
        var term = filters["term"] as! String
        Business.searchWithParams(filters, completion: {
            (businessCollection, error) -> Void in
            self.businesses = businessCollection.businesses
            self.total      = businessCollection.total
            println("total: \(self.total)")
            self.tableView.reloadData()
        })
    }


    func loadBusinessesWhileScrolling(var filters: [String:AnyObject]) {

        println("loading \(filters)")
        self.offset = offset + limit
        filters["offset"] = offset

        if offset < total {
            Business.searchWithParams(filters, completion: {
                (businessCollection, error) -> Void in
                self.businesses = businessCollection.businesses
                self.total = businessCollection.total
                println("total: \(self.total)")
                self.tableView.reloadData()
                self.tableView.finishInfiniteScroll()
            })
        } else {
            self.tableView.finishInfiniteScroll()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return scopedBusinesses?.count ?? 0
        } else {
            return businesses?.count ?? 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell

        if isSearching {
            cell.business = scopedBusinesses![indexPath.row]
        } else {
            cell.business = businesses[indexPath.row]
        }
        
        return cell
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) { // called when keyboard search button pressed
        println("searching \(searchBar.text)")
        if !searchBar.text.isEmpty {
            self.isSearching = true
            // use this if we want to filter results without via API
            // scopedBusinesses = businesses.filter({ (biz:Business) -> Bool in
            //   let found = biz.name?.rangeOfString(searchBar.text, options: NSStringCompareOptions.CaseInsensitiveSearch)
            //   return found != nil
            // })

            self.offset = 0
            Business.searchWithTerm(searchBar.text, completion: { (businesses, error) -> Void in
                self.scopedBusinesses = businesses
                self.tableView.reloadData()
                println("reloaded data")
            })
        } else {
            tableView.reloadData()
        }
        searchBar.endEditing(true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) { // called when cancel button pressed
        println("cancel search")
        self.isSearching = false
        tableView.reloadData()
    }

//    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
//        println("result list clicked")
//        tableView.reloadData()
//    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.isSearching = false
        }
        tableView.reloadData()
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        let nc = segue.destinationViewController as! UINavigationController
        let fvc = nc.topViewController as! FiltersViewController
        fvc.delegate = self
    }

    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        self.currentFilters = filters
        loadBusinesses(filters)
    }
}
