//
//  FloorsViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 14.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK

class FloorsViewController: UITableViewController {

    var venue : IFMVenue?
    var floors : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Venue: %@ name: %@", self.venue!.remote_id, self.venue!.name)
        self.title = "\(self.venue!.name) - Floors"
        self.fetchFloors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - IfinitySDK Calls
    
    func fetchFloors() {
        IFDataManager.sharedManager().fetchFloorsFromCacheForVenueId(self.venue!.remote_id, block: {floors in
            NSLog("Fetch floors success with count: \(floors.count)")
            self.floors = floors
            if (self.refreshControl != nil) {
                let formatter: NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "MMM d, h:mm a"
                let lastUpdated: String = "Last updated on \(formatter.stringFromDate(NSDate()))"
                self.refreshControl!.attributedTitle = NSAttributedString(string: lastUpdated)
                self.refreshControl!.endRefreshing()
            }
            self.tableView.reloadData()
        })
    }
    

    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.floors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath)
        let floor: IFMFloorplan = self.floors[indexPath.row] as! IFMFloorplan
        cell.textLabel!.text = "floor \(floor.label)"
        
        return cell
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ContentViewController {
            let url = NSURL(string: self.venue!.content.getContentURL())
            let destinationVC = segue.destinationViewController as! ContentViewController
            destinationVC.url = url
        }
        else if segue.destinationViewController is FloorplanChild && sender is UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let destinationVC = segue.destinationViewController as! FloorplanChild
            destinationVC.floor = self.floors[indexPath!.row] as? IFMFloorplan
        }
    }

}
