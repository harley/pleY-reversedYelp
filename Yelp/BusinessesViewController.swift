//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

    //    var businessCollection: [BusinessCollection]!
    var businesses: [Business]!
    var scopedBusinesses: [Business]?
    
    @IBOutlet weak var tableView: UITableView!

    var searchBar: UISearchBar!
    var isSearching: Bool = false
    var currentFilters = [String : AnyObject]()
    
    var offset: Int = 0
    let limit: Int = 20
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


        searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self

        loadBusinesses(currentFilters)

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
        println("loading by \(filters)")
        self.isSearching = false

        if filters["term"] != nil {
            searchBar.text = filters["term"] as! String
        }

        Business.searchWithParams(filters, completion: {
            (businessCollection, error) -> Void in
            if businessCollection != nil {
                self.businesses = businessCollection.businesses
                self.total      = businessCollection.total
                println("total businesses loaded: \(self.total)")
                self.tableView.reloadData()
            } else {
                println("**Search returns nothing. Check limit, other params or the Internet**")
            }
        })
    }

    func loadBusinessesWhileScrolling(var filters: [String:AnyObject]) {
        self.offset = offset + limit
        filters["offset"] = offset

        println("current total: \(total); loading by \(filters)")

        if offset < total {
            Business.searchWithParams(filters, completion: {
                (businessCollection, error) -> Void in
                if businessCollection != nil {
                    self.appendDatasource(businessCollection.businesses)

                    self.total = businessCollection.total
                    println("[scrolling] total: \(self.total)")
                    self.tableView.reloadData()
                } else {
                    println("**Search returns nothing. Check limit or other params**")
                }
                self.tableView.finishInfiniteScroll()
            })
        } else {
            self.tableView.finishInfiniteScroll()
        }
    }

    func appendDatasource(bizzes: [Business]!) {
        if isSearching {
            self.scopedBusinesses?.extend(bizzes)
        } else {
            self.businesses.extend(bizzes)
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

    func mapFilterSectionToFilters(filterSections: [FilterSection]!) -> [String:AnyObject] {
        var filters = [String : AnyObject]()
        filters["deals"] = filterSections[0].aggregatedFormInput()
        filters["radius"] = filterSections[1].aggregatedFormInput()
        filters["sort"] = filterSections[2].aggregatedFormInput()

        let cat = filterSections[3].aggregatedFormInputs()
        filters["categories"] = cat.isEmpty ? nil : cat

        return filters
    }

    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filterSections: [FilterSection]) {
        self.currentFilters = mapFilterSectionToFilters(filterSections)
        FilterManager.savedInstance = filterSections
        loadBusinesses(currentFilters)
    }
}
