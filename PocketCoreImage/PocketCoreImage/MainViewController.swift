//
//  MainViewController.swift
//  PocketCoreImage
//
//  Translated by OOPer in cooperation with shlab.jp, on 2016/1/2.
//
//
/*
     File: MainViewController.h
     File: MainViewController.m
 Abstract: View controller for the interface.  Manages the filtered image view and list of filters.
  Version: 1.0

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2011 Apple Inc. All Rights Reserved.

 */

import UIKit
import QuartzCore

@objc(MainViewController)
class MainViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    // Array of CIFilters currently applied to the image.
    var filtersToApply: [CIFilter] = []
    // Array created at startup containg the names of filters that can be applied to the image.
    var _availableFilters: [String] = []
    
    @IBOutlet var imageView: FilteredImageView!
    @IBOutlet var tableView: UITableView!
    
    //
    // Action sent by the right navigation bar item.
    // Removes all applied filters and updates the display.
    @IBAction func clearFilters(_: AnyObject) {
        filtersToApply.removeAll()
        
        // Instruct the filtered image view to refresh
        imageView.reloadData()
        // Instruct the table to refresh.  This will remove
        // any checkmarks next to selected filters.
        tableView.reloadData()
    }
    
    //
    // Private method to add a filter given it's name.
    // Creates a new instance of the named filter and adds
    // it to the list of filters to be applied, then
    // updates the display.
    private func addFilter(name: String) {
        // Create a new filter with the given name.
        guard let newFilter = CIFilter(name: name) else {
            // A nil value implies the filter is not available.
            return
        }
        
        // -setDefaults instructs the filter to configure its parameters
        // with their specified default values.
        newFilter.setDefaults()
        // Our filter configuration method will attempt to configure the
        // filter with random values.
        MainViewController.configureFilter(newFilter)
        
        filtersToApply.append(newFilter)
        
        // Instruct the filtered image view to refresh
        imageView.reloadData()
    }
    
    //
    // Private method to add a filter given it's name.
    // Updates the display when finished.
    private func removeFilter(name: String) {
        
        // Find the index named filter in the array.
        if let filterIndex = filtersToApply.indexOf({$0.name == name}) {
            // If it was found (which it always should be) remove it.
            filtersToApply.removeAtIndex(filterIndex)
        }
        
        // Instruct the filtered image view to refresh
        imageView.reloadData()
    }
    
    //MARK: - TableView
    
    // Standard table view datasource/delegate code.
    //
    // Create a table view displaying all the filters named in the _availableFilters array.
    // Only the names of the filters a stored in the _availableFilters array, the actual filter
    // is created on demand when the user chooses to add it to the list of applied filters.
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _availableFilters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let filterCellID = "filterCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(filterCellID)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: filterCellID)
        }
        
        cell!.textLabel!.text = _availableFilters[indexPath.row]
        
        // Check if the filter named in this row is currently applied to the image.  If it is,
        // give this row a checkmark.
        cell!.accessoryType = .None
        if filtersToApply.indexOf({$0.name == _availableFilters[indexPath.row]}) != nil {
            cell!.accessoryType = .Checkmark
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a Filter"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        // Determine if the filter is or is not currently applied.
        let filterIsCurrentlyApplied = filtersToApply.indexOf({$0.name == selectedCell?.textLabel?.text}) != nil
        
        // If the filter is currently being applied, remove it.
        if filterIsCurrentlyApplied {
            self.removeFilter(_availableFilters[indexPath.row])
            tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .None
            // Otherwise, add it.
        } else {
            self.addFilter(_availableFilters[indexPath.row])
            tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .Checkmark;
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersToApply = []
        
        imageView.inputImage = UIImage(named: "LakeDonPedro2.jpg")
        
    }
    
    override func awakeFromNib() {
        _availableFilters = ["CIColorInvert", "CIColorControls", "CIGammaAdjust", "CIHueAdjust"]
    }

}