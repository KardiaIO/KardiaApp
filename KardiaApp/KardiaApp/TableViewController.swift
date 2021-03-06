//
//  TableViewController.swift
//  KardiaApp
//
//  Created by Bernie Chu on 1/13/15.
//  Copyright (c) 2015 Kardia. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet var arrhythmiaTable: UITableView!
    
    /**
    * Prevent autorotation
    */
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register table cell for reuse
        self.arrhythmiaTable?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Add event listener for new abnormalities in order to update view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("redrawTable"), name: "Abnormality", object: nil)

    }
    
    /**
    * Arrhythmia table protocol - datasource arrhythmiaTimes is defined in the ViewController
    */
    
    // Number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrhythmiaTimes.count
    }
    
    // Rendering of cells with timestamp and description
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.arrhythmiaTable?.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = TimestampFromDate(arrhythmiaTimes[indexPath.row])
        cell.textLabel?.font = UIFont(name: "STHeitiTC-Light", size: 16)
        cell.detailTextLabel?.text = "Arrhythmia"
        cell.detailTextLabel?.font = UIFont(name: "Helvetica-LightOblique", size: 12)
        cell.detailTextLabel?.textColor = UIColor.redColor()
        dispatch_async(dispatch_get_main_queue()) {
            cell.backgroundColor = UIColor.clearColor()
        }
        return cell
    }
    
    // Required delegate method for row selection; does nothing
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    // Allows rows to be deleted
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            arrhythmiaTimes.removeAtIndex(indexPath.row)
            arrhythmiaTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // Method called by interval timer to constantly update human-readable time strings in arrhythmia events table
    func redrawTable() {
        dispatch_async(dispatch_get_main_queue()) {
            self.arrhythmiaTable.reloadData()
        }
    }
}