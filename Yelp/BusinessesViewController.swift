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
    var scopedBusinesses: [Business]?
    
    @IBOutlet weak var tableView: UITableView!

    var searchBar: UISearchBar!
    var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100


//        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            
//            for business in businesses {
//                println(business.name!)
//                println(business.address!)
//            }
//        })
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
            for business in businesses {
                println(business.name!)
                println(business.address!)
            }
        }

        searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
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

    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        println("result list clicked")
        tableView.reloadData()
    }

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
        println("filters: \(filters)")
        var categories = filters["categories"] as? [String]
        var deals = filters["deals"] as? Bool
        var sort:YelpSortMode?
        if filters["sort"] != nil {
            sort = YelpSortMode(rawValue: filters["sort"] as! Int)
        } else {
            sort = nil
        }
        var term = filters["term"] as? String
        Business.searchWithTerm("Restaurants", sort: sort, categories: categories, deals: deals, completion: {
            (businesses, error) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
        
    }
}
