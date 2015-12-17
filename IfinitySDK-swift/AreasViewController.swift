//
//  AreasViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 14.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK

class AreasViewController: UITableViewController, FloorplanChild {
    
    var floor: IFMFloorplan?
    var areas: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Floor \(self.floor!.label) - Areas"
        self.fetchAreas()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchAreas() {
        IFDataManager.sharedManager().fetchAreasFromCacheForFloorId(self.floor!.remote_id, block: {areas in
            NSLog("Fetch areas success")
            self.areas = areas
            if self.refreshControl != nil {
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
        return self.areas.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath)
        let area = self.areas[indexPath.row] as! IFMArea
        cell.textLabel!.text = area.name
        
        if area.contents.count >= 1 {
            let content = area.contents.first as! IFMContent
            if IFMContentTypeNone == Int(content.type) {
                cell.accessoryType = .None
                cell.userInteractionEnabled = false
            } else {
                cell.accessoryType = .DisclosureIndicator;
                cell.userInteractionEnabled = true
            }
        } else {
            cell.accessoryType = .None
            cell.userInteractionEnabled = false
        }
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationViewController is ContentViewController && sender is UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let area = self.areas[indexPath!.row]
            let content = area.contents!.first as! IFMContent
            let url = NSURL(string: content.getContentURL())
            let destinationVC = segue.destinationViewController as! ContentViewController
            destinationVC.url = url
        } else  if segue.destinationViewController is FloorplanChild {
            (segue.destinationViewController as! FloorplanChild).floor = self.floor
        }
    }

}
