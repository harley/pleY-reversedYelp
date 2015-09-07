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
        tableView.estimatedRowHeight = 120


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
            return scopedBusinesses!.count
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
            scopedBusinesses = businesses.filter({ (biz:Business) -> Bool in
                let found = biz.name?.rangeOfString(searchBar.text, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return found != nil
            })
        }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) { // called when cancel button pressed
        println("cancel search")
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
        var categories = filters["categories"] as? [String]
        Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals: nil) {
            (businesses, error) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
        
    }
}
