//
//  BusinessCollection.swift
//  Yelp
//
//  Created by Harley Trung on 9/8/15.
//  Copyright (c) 2015 Harley Trung. All rights reserved.
//

import UIKit

class BusinessCollection {
    let total: Int
    let businesses: [Business]

    init(businesses: [Business], total: Int) {
        self.total = total
        self.businesses = businesses
    }
}
