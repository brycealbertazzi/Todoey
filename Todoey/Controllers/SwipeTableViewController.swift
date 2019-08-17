//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/14/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import UIKit
import SwipeCellKit


class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.rowHeight = 80
        navigationController?.navigationBar.barTintColor = UIColor.flatGreen()
    }
    
    //MARK: - Table view datasource methods
    let CELL_KEY: String = "Cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_KEY, for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        print("Cell loaded")
        return cell
    }
    
    //MARK: - Swipe cell delegate methods
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        /*Code for when a user swipes on a cell*/
        
        //Ensures the swipe is from the right side
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            //Update model with deletion
            print("Delete Cell")
            self.updateModel(at: indexPath)
//
        }
        
        //customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        //Update our data model
        //This method is overriden in child classes
    }
    
    

}

