//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Harley Trung on 9/7/15.
//  Copyright (c) 2015 Harley Trung. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String:String]]!
    var switchStates = [Int:[Int:Bool]]()

    var showAllCategories: Bool! = false
    let minimumNumberOfCategoriesToShow = 3

    // order of filters:
    // deals
    // distance
    // sort by
    // category


    //  ["name": "Deals", "code": "deals_filter"],
    //  ["name": "Distance", "code": "radius_filter"],
    //  ["name": "Sort By", "code": "sort"],
    //  ["name": "Category", "code": "category_filter"]

    var filterSections: [FilterSection]!
    
    let mileToMeter = 1609.34
    let radiusFilterValues:[Double?] = [nil, 0.3, 1, 5, 20]
//    let sortFilterValues = [YelpSortMode.BestMatched, YelpSortMode.Distance, YelpSortMode.HighestRated]

    func numberOfCategoriesToShow() -> Int {
        if showAllCategories! {
            return categories.count
        } else {
            return minimumNumberOfCategoriesToShow
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        categories = FilterSection.yelpCategories()
        // Do any additional setup after loading the view.

        // Should be in an initialize but we're lazy here

        let deals = FilterSection(name: "Deals", collapsable: false, multipleChoice: false, filterInputs: [FilterInput(name: "Offer A Deal", code: true)])
        let distance = FilterSection(name: "Distance", collapsable: true, multipleChoice: false, filterInputs: [
                FilterInput(name: "Auto", code: nil),
                FilterInput(name: "0.3 mile", code: 0.3),
                FilterInput(name: "1 mile", code: 1),
                FilterInput(name: "5 miles", code: 5),
                FilterInput(name: "20 miles", code: 20)
            ])
        let sort = FilterSection(name: "Sort By", collapsable: true, multipleChoice: false,
            filterInputs: [
                FilterInput(name: "Best Match", code: 0),
                FilterInput(name: "Distance", code: 1),
                FilterInput(name: "Rating", code: 2)
            ])
        
        let category = FilterSection(name: "Category", collapsable: false, multipleChoice: true,
            filterInputs: categories.map({ (e:[String:String]) -> FilterInput in
                let name: String = e["name"]!
                let code: AnyObject? = e["code"] as? AnyObject
                return FilterInput(name: name, code: code)
            })
        )
        
        filterSections = [deals, distance, sort, category]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)

        var filters = [String : AnyObject]()
        filters["terms"] = "Restaurants"

        for (section, sectionSwitches) in switchStates {
            println("checking section \(section): \(sectionSwitches)")
            switch section {
            case 0:
                filters["deals"] = sectionSwitches[0]! // only one value
            case 1:
                filters["radius"] = nil
                for (key, value) in sectionSwitches {
                    if value {
                        if let mile = radiusFilterValues[key] {
                            filters["radius"] = mile * mileToMeter
                        }
                        break
                    }
                }
            case 2:
                filters["sort"] = nil
                for (key, value) in sectionSwitches {
                    if value {
                        filters["sort"] = key
                        break
                    }
                }
            case 3:
                var selectedCategories = [String]()
                println("sectionSwitches for categories: \(sectionSwitches)")
                for (row, isSelected) in sectionSwitches {
                    if isSelected {
                        selectedCategories.append(categories[row]["code"]!)
                    }
                }
                if selectedCategories.count > 0 {
                    filters["categories"] = selectedCategories
                }
            default:
                true
            }
        }
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterSections[section].numberOfVisibleFilterInputs()
    }

    // TODO: refactor for categories
    func showSeeAllToggle(indexPath: NSIndexPath) -> Bool {
        return !showAllCategories && (indexPath.section == 3) && (indexPath.row == numberOfCategoriesToShow()-1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if showSeeAllToggle(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier("SeeAllToggleCell", forIndexPath: indexPath) as! SeeAllToggleCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell

            let filterInput = filterSections[indexPath.section].filterInputs[indexPath.row]
            cell.switchLabel.text = filterInput.name
            
            // TODO custom input besides onSwitch
            cell.onSwitch.on = switchStates[indexPath.section]?[indexPath.row] ?? false

            cell.delegate = self
            return cell
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filterSections.count
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        headerView.backgroundColor = UIColor.darkGrayColor()

        var titleLabel = UILabel(frame: CGRect(x: 5, y: 2, width: 320, height: 20))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font.fontWithSize(12)

        titleLabel.text = filterSections[section].name

        headerView.addSubview(titleLabel)

        return headerView
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        if (cell is SeeAllToggleCell) {
            // TODO: convert to collapsable section here?
            if showSeeAllToggle(indexPath) {
                self.showAllCategories = true
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }

    // MARK: - SwitchCellDelegate

    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        println("\(indexPath.row)")
        switchStates[indexPath.section] = switchStates[indexPath.section] ?? [Int:Bool]()
        switchStates[indexPath.section]![indexPath.row] = value
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
