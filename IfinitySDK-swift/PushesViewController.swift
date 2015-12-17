//
//  PushesViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 15.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK

class PushesViewController: UITableViewController {

    var pushes:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pushes"
        self.listPushes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func listPushes() {
        self.pushes = IFPushManager.sharedManager().fetchAll()
        if self.refreshControl != nil {
            let formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            let lastUpdated: String = "Last updated on \(formatter.stringFromDate(NSDate()))"
            self.refreshControl?.attributedTitle = NSAttributedString(string: lastUpdated)
            self.refreshControl?.endRefreshing()
        }
        self.tableView.reloadData()
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pushes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1")!
        let push = self.pushes[indexPath.row] as! IFMPush
        cell.textLabel!.text = push.name
        if Int(push.type) == IFMPushTypeLocal || Int(push.type) == IFMPushTypeLocalBackground {
            cell.accessoryType = .DisclosureIndicator
            cell.userInteractionEnabled = true
        }
        else {
            cell.accessoryType = .None
            cell.userInteractionEnabled = false
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if sender is UITableViewCell && segue.destinationViewController is ContentViewController {
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            let push = self.pushes[indexPath.row] as! IFMPush
            let destinationVC = segue.destinationViewController as! ContentViewController
            
            switch Int(push.type) {
            case IFMPushTypeRemote:
                if push.url != nil {
                    destinationVC.url = NSURL(string: push.url)
                } else if push.content != nil {
                    destinationVC.content = push.content
                }
            case IFMPushTypeLocalBackground:
                fallthrough
            case IFMPushTypeLocal:
                let content = IFMContent.fetchContentWithRemoteID(push.pushLocal.content_id, managedObjectContext: nil)
                destinationVC.url = NSURL(string: content.getContentURL()!)
            default:
                    break
            }
        }
    }
}
