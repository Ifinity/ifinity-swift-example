//
//  IndoorLocationViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 15.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK

class IndoorLocationViewController: UIViewController, IFBluetoothManagerDelegate, IFIndoorLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView?
    var currentFloor: IFMFloorplan?
    var indoorLocationManager: IFIndoorLocationManager?
    var userAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.currentFloor?.venue.name

        // If we want to see more zoom levels
        IFLocationManager.sharedManager().setZoomFactor(2)
        IFLocationManager.sharedManager().setTranslationCoordinate(currentFloor!.center())
        let center = IFLocationManager.sharedManager().translateCoordinate(currentFloor!.center());

        // User annotation will display my current indoor position
        self.userAnnotation = MKPointAnnotation()
        self.userAnnotation?.coordinate = center;
        self.mapView?.addAnnotation(self.userAnnotation!)
        
        // To receive updates about indoor position and user location
        self.indoorLocationManager = IFIndoorLocationManager()
        self.indoorLocationManager?.delegate = self
        self.updateMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start looking for beacons around me
        IFBluetoothManager.sharedManager().startManager()
        IFBluetoothManager.sharedManager().delegate = self
        self.indoorLocationManager?.startUpdatingIndoorLocation()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushAdd, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop looking for beacons around me
        IFBluetoothManager.sharedManager().delegate = nil
        self.indoorLocationManager?.stopUpdatingIndoorLocation()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IFPushManagerNotificationPushAdd, object: nil)
    }
    
    func addAreasToMap() {
        let areas: [IFMArea] = Array(self.currentFloor!.areas) as! [IFMArea]
        for area in areas {
            var areaPoints: [IFMAreaPoint] = Array(area.points) as! [IFMAreaPoint]
            var pointsToUse: [CLLocationCoordinate2D] = []
            areaPoints = areaPoints.sort {
                return $0.order.intValue > $1.order.intValue
            }
            for areaPoint in areaPoints {
                let c: CLLocationCoordinate2D = IFLocationManager.sharedManager().translateCoordinate(CLLocationCoordinate2DMake((areaPoint.lat as Double), (areaPoint.lng as Double)))
                pointsToUse.append(c)
            }
            let polygon: MKPolygon = MKPolygon(coordinates: &pointsToUse, count: areaPoints.count)
            polygon.title = "IFAreasOverlay"
            self.mapView?.addOverlay(polygon, level: .AboveLabels)
        }
    }
    
    func addBeaconsToMap() {
        let beacons: [IFMBeacon] = Array(self.currentFloor!.beacons) as! [IFMBeacon]
        for beacon in beacons {
            let c: CLLocationCoordinate2D = IFLocationManager.sharedManager().translateCoordinate(beacon.location().coordinate)
            let ann = IFBeaconAnnotation(coordinate: c)
            ann.setTitle(beacon.name)
            self.mapView?.addAnnotation(ann)
        }
    }
    
    func resetMap() {
        self.indoorLocationManager?.startCheckingAreasForFloorplan(nil)
        self.mapView?.removeOverlays(self.mapView!.overlays)
        for item in self.mapView!.annotations {
            if !(item is MKPointAnnotation) {
                self.mapView?.removeAnnotation(item)
            }
        }
    }
    
    func updateMap() {
        self.resetMap()

        let center = IFLocationManager.sharedManager().translateCoordinate(self.currentFloor!.center());
        let camera: MKMapCamera = MKMapCamera(lookingAtCenterCoordinate: center, fromEyeCoordinate: center, eyeAltitude: 300)
        self.mapView?.setCamera(camera, animated: false)
        self.userAnnotation?.coordinate = center
        
        let overlay:IFTileOverlay = IFTileOverlay()
        overlay.mapURL = self.currentFloor?.map_id
        self.mapView?.addOverlay(overlay, level: .AboveLabels)
        
        self.addAreasToMap()
        self.addBeaconsToMap()
        self.indoorLocationManager?.startCheckingAreasForFloorplan(self.currentFloor)
    }
    
    
    //MARK: - Pushes
    
    func addPush(sender: AnyObject) {
        let dict: [NSObject : AnyObject] = sender.userInfo
        let push: IFMPush = dict["push"] as! IFMPush
        NSLog("Indoor Location New Push: %@", push.name)
    }
    
    
    //MARK: - IFBluetoothManagerDelegate
    
    func manager(manager: IFBluetoothManager, didDiscoverActiveBeaconsForVenue venue: IFMVenue?, floorplan: IFMFloorplan) {
        if venue == nil {
            return
        }
        if Int(venue!.type) == IFMVenueTypeMap {
            if self.currentFloor != nil && !(self.currentFloor?.venue_id == venue?.remote_id) {
                self.manager(manager, didLostAllBeaconsForVenue: self.currentFloor!.venue)
            }
            else if self.currentFloor == nil || !(self.currentFloor?.remote_id == floorplan.remote_id) {
                self.currentFloor = floorplan
                self.updateMap()
            }
        }
    }
    
    func manager(manager: IFBluetoothManager, didLostAllBeaconsForVenue venue: IFMVenue) {
        self.currentFloor = nil
        IFBluetoothManager.sharedManager().delegate = nil
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func manager(manager: IFBluetoothManager, didLostAllBeaconsForFloorplan floorplan: IFMFloorplan) {
        
    }
    
    
    //MARK - IFIndoorLocationManagerDelegate
    
    func manager(manager: IFIndoorLocationManager, didUpdateIndoorLocation location: CLLocation) {
        self.userAnnotation!.coordinate = IFLocationManager.sharedManager().translateCoordinate(location.coordinate)
    }
    
    func manager(manager: IFIndoorLocationManager, didEnterArea area: IFMArea) {
        NSLog("Did enter into area: %@", area.name)
    }
    
    func manager(manager: IFIndoorLocationManager, didExitArea area: IFMArea) {
        NSLog("Did exit from area: %@", area.name)
    }
    
    
    //MARK: - MKMapViewDelegate

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is IFTileOverlay {
            return IFTileOverlayRenderer(overlay: overlay)
        }
        else if overlay is MKPolygon {
            let polygonView: MKPolygonRenderer = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.clearColor()
            polygonView.fillColor = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.5)
            return polygonView
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // UserAnnotation with some nice icon
        if annotation is MKPointAnnotation {
            let annotationUserReuseIdentifier: String = "IFUser"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationUserReuseIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationUserReuseIdentifier)
            }
            annotationView!.image = UIImage(named: "ico_you")
            annotationView!.centerOffset = CGPointMake(0, 0)
            annotationView!.annotation = annotation
            return annotationView
        }
        
        // IFBeaconAnnotation with some nice icon
        if annotation is IFBeaconAnnotation {
            let annotationUserReuseIdentifier: String = "IFBeacon"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationUserReuseIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationUserReuseIdentifier)
            }
            annotationView!.image = UIImage(named: "ico_beacon")
            annotationView!.centerOffset = CGPointMake(0, 0)
            annotationView!.annotation = annotation
            return annotationView
        }
        return nil
    }
}