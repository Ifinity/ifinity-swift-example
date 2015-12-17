//
//  ViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 10.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK
import SVProgressHUD

class VenuesViewController: UITableViewController {
    
    var venues : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if IFDataManager.sharedManager().authenticated() {
            self.loadVenues()
        } else {
            self.authenticate()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        IFBluetoothManager.sharedManager().delegate = nil
        IFBluetoothManager.sharedManager().stopManager()
        super.viewWillAppear(animated)
    }
    
    
    //MARK: - Authorize & data Fetching
    
    func authenticate() {
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
        IFDataManager.sharedManager().authenticateWithSuccess({credential in
            self.loadVenues()
            SVProgressHUD.dismiss()
            }, failure: {error in
                NSLog("Invalid authentication with error %@", error)
        })
    }
    
    func loadVenues() {
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
        IFDataManager.sharedManager().loadDataForLocation(CLLocation(latitude: 52, longitude: 21), distance: 1000, withPublicVenues: true, successBlock: { (venues) -> Void in
            NSLog("LoadDataForLocation success.")
            self.fetchVenues()
            SVProgressHUD.dismiss()
            }) { (error) -> Void in
                NSLog("LoadDataForLocation error %@", error)
        }
    }
    
    
    //MARK: - IfinitySDK operations

    func fetchVenues(){
        IFDataManager.sharedManager().fetchVenuesFromCacheWithBlock { venues in
            NSLog("Fetch venues success.")
            self.venues = venues
            if (self.refreshControl != nil) {
                let formatter: NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "MMM d, h:mm a"
                let lastUpdated: String = "Last updated on \(formatter.stringFromDate(NSDate()))"
                self.refreshControl!.attributedTitle = NSAttributedString(string: lastUpdated)
                self.refreshControl!.endRefreshing()
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func clearCaches(sender: AnyObject) {
        IFDataManager.sharedManager().clearCaches()
        self.loadVenues()
    }
    
    
    //MARK: - TableView Delegates

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell1")!
        let venue = self.venues[indexPath.row]
        cell.textLabel!.text = venue.name
        return cell
    }
    
    
    //MARK: - UIView animations
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is FloorsViewController && sender is UITableViewCell {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let venue = self.venues[indexPath!.row] as! IFMVenue
            let destinationVC: FloorsViewController = segue.destinationViewController as! FloorsViewController
            destinationVC.venue = venue
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

