//
//  VenuesMapViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 15.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK
import MapKit
import SVProgressHUD

class VenuesMapViewController: UIViewController, MKMapViewDelegate, IFBluetoothManagerDelegate {

    @IBOutlet var mapView: MKMapView?
    var currentVenue: IFMVenue?
    var currentFloor: IFMFloorplan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Navigation"
    }
    
    override func viewWillAppear(animated: Bool) {
        // Start looking for beacons around me
        IFBluetoothManager.sharedManager().delegate = self
        IFBluetoothManager.sharedManager().startManager()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushAdd, object: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        IFBluetoothManager.sharedManager().delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IFPushManagerNotificationPushAdd, object: nil)
    }
    
    
    //MARK: - Pushes
    
    func addPush(sender: AnyObject) {
        var dict: [NSObject : AnyObject] = sender.userInfo
        let push: IFMPush = dict["push"] as! IFMPush
        NSLog("Venue Map New Push: %@", push.name)
    }
    
    @IBAction func clearCaches(sender: AnyObject) {
        IFBluetoothManager.sharedManager().delegate = nil
        SVProgressHUD.showWithMaskType(.Black)
        IFDataManager.sharedManager().clearCaches()
        IFDataManager.sharedManager().loadDataForLocation(CLLocation(latitude: 52, longitude: 21), distance: 1000, withPublicVenues: true, successBlock: { (venues) -> Void in
            SVProgressHUD.dismiss()
            IFBluetoothManager.sharedManager().delegate = self
            }) { (error) -> Void in
                NSLog("LoadDataForLocation error %@", error)
        }
    }
    
    
    //MARK: - IFBluetoothManagerDelegates
    
    func manager(manager: IFBluetoothManager, didDiscoverActiveBeaconsForVenue venue: IFMVenue?, floorplan: IFMFloorplan) {
        guard venue != nil else {
            return
        }
        if Int(venue!.type) == IFMVenueTypeMap {
            
            NSLog("IFMVenueTypeMap %s", __FUNCTION__)
            self.currentVenue = venue
            self.currentFloor = floorplan
            IFBluetoothManager.sharedManager().delegate = nil
            self.performSegueWithIdentifier("IndoorLocation", sender: self)
            
        } else if Int(venue!.type) == IFMVenueTypeBeacon {
            NSLog("IFMVenueTypeBeacon %s", __FUNCTION__)
            if self.currentVenue?.remote_id == venue?.remote_id {
                return
            }
            // Center map to venue center coordinate
            let center = CLLocationCoordinate2DMake(Double(venue!.center_lat), Double(venue!.center_lng))
            let venueAnnotation = VenueAnnotation(coordinate: center, title: venue!.name, subtitle: "")
            let distance: CLLocationDistance = 800.0
            let camera = MKMapCamera(lookingAtCenterCoordinate: center, fromEyeCoordinate: center, eyeAltitude: distance)
            self.mapView?.addAnnotation(venueAnnotation)
            self.mapView?.setCamera(camera, animated: false)
        }

        self.currentVenue = venue
    }
    
    func manager(manager: IFBluetoothManager, didLostAllBeaconsForVenue venue: IFMVenue) {
        self.currentVenue = nil
        self.mapView?.removeAnnotations(self.mapView!.annotations)
    }
    
    func manager(manager: IFBluetoothManager, didLostAllBeaconsForFloorplan floorplan: IFMFloorplan) {
        self.currentFloor = nil
        self.mapView?.removeAnnotations(self.mapView!.annotations)
    }
    
    
    //MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // VenueAnnotation with some nice icon
        if annotation is VenueAnnotation {
            let annotationIdentifier: String = "venueIdentifier"
            let pinView: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            pinView.pinTintColor = UIColor.greenColor()
            pinView.canShowCallout = true
            return pinView
        }
        return nil
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is IndoorLocationViewController {
            (segue.destinationViewController as! IndoorLocationViewController).currentFloor = self.currentFloor
        }
    }

}
