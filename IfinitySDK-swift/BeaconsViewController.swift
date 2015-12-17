//
//  BeaconsViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 14.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK

class BeaconsViewController: UITableViewController, FloorplanChild {

    var floor: IFMFloorplan?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Floor \(self.floor!.label) - Beacons"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UITableViewDelegates
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.floor!.beacons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath)
        let beacons = Array(self.floor!.beacons)
        let beacon = beacons[indexPath.row] as! IFMBeacon
        cell.textLabel!.text = beacon.name
        
        return cell
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
