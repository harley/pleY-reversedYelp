//
//  DetailViewController.swift
//  Yelp
//
//  Created by Harley Trung on 9/9/15.
//  Copyright (c) 2015 Harley Trung. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var categoriesLabel: UILabel!

    @IBOutlet weak var thumbImageView: UIImageView!

    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    var business: Business!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        nameLabel.text = business.name
        thumbImageView.setImageWithURL(business.imageURL)
        categoriesLabel.text = business.categories
        addressLabel.text = business.address
        reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
        ratingImageView.setImageWithURL(business.ratingImageURL)
        // distanceLabel.text = business.distance

        mapView.delegate = self

        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        mapView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - MapView
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKPointAnnotation) {
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                view!.canShowCallout = false
            }
            return view
        }
        else {
            return nil
        }
    }
}
