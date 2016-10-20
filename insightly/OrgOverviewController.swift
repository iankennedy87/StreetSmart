//
//  OrgOverviewController.swift
//  insightly
//
//  Created by Ian Kennedy on 31/07/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import GoogleMaps
import MapKit

class OrgOverviewController: UIViewController {
    
    @IBOutlet weak var streetView: UIView!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var org: Organisation!
    var firstView: Bool = true
    
    let del = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.hidesWhenStopped = true
        streetView.setNeedsLayout()
        streetView.layoutIfNeeded()
        self.navigationItem.title = org.name!
        addressLabel.text = org.addressByLine
        //If organisation hasn't been viewed yet, attempt to geocode coordinates
        if firstView {
            spinner.startAnimating()
            getCoordinatesFromAddressString(organisation: org, completionHandler: { (success) in
                
                self.org.geocodeComplete = true
                if success {
                    self.org.geocodeSuccess = true
                    
                } else {
                    self.org.geocodeSuccess = false
                    //alert user if geocode fails
                    let alert = UIAlertController(title: "Geocoding failed", message: "Could not find a Google StreetView for \(self.org.name!)'s address. Check the address and try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                self.del.saveContext()
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.renderStreetView(geocodeSuccess: self.org.geocodeSuccess)
                }
            })
        }
      }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //renders street view if geocode has already occurred
        if !firstView {
            renderStreetView(geocodeSuccess: org.geocodeSuccess)
        }
    }
    
    //renders street view or placeholder depending on geocode result
    func renderStreetView(geocodeSuccess: Bool) -> Void {
        if geocodeSuccess {
            
            let coordinate = CLLocationCoordinate2DMake(self.org.latitude, self.org.longitude)
            let streetViewFrame = self.streetView.frame
            let panoview = GMSPanoramaView(frame: streetViewFrame)
            panoview.contentMode = .scaleAspectFit
            self.view.addSubview(panoview)
            self.view.bringSubview(toFront: panoview)
            panoview.moveNearCoordinate(coordinate)
        } else {
    
            let placeholder = UIImage(named: "placeholder")!
            let placeholderView = UIImageView(image: placeholder)
            placeholderView.frame = self.streetView.frame
            placeholderView.frame.origin = self.streetView.frame.origin
            placeholderView.contentMode = .scaleToFill
            self.view.addSubview(placeholderView)
            self.view.bringSubview(toFront: placeholderView)
        }
    }
   
    //geocode organisation address and save coordinates to core data
    func getCoordinatesFromAddressString(organisation: Organisation, completionHandler: @escaping (_ success: Bool) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(organisation.address!) { (placemarks, error) in
            
            var coordinate : CLLocationCoordinate2D? = nil
            guard (error == nil) else {
                print("Geocoding failed for address: \(organisation.address) organisation: \(organisation.name)")
                completionHandler(false)
                return
            }
            
            guard let placemark = placemarks![0] as CLPlacemark? else {
                print("No placemarks found")
                completionHandler(false)
                return
            }
            coordinate = placemark.location!.coordinate
            
            let latitude = coordinate!.latitude
            let longitude = coordinate!.longitude
            print("Geocoding succeeded for organisation: \(organisation.name) latitude: \(latitude) longitude: \(longitude)")
            organisation.latitude = latitude
            organisation.longitude = longitude
            DispatchQueue.main.async(execute: {
                self.del.saveContext()
            })
            completionHandler(true)
        }
    }
}
