//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/9/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    let ITEM_ARRAY_KEY: String = "ItemArrayKey"
    var itemArray: [Item] = [Item]()
    //userDomainMask is the user's home directory
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Load items from DB
        loadItems()
    }
    
    
    //MARK: - Model Manipulation Methods
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //UIApplication.shared corresponds to the current app as an object
    
    func saveItems() {
        //Save itemArray into DB
        do {
           try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = /*Default Val*/ Item.fetchRequest()) {
        //Read data from database
        do {
         itemArray = try context.fetch(request) //Load itemArray with the contents from the request
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    let CELL_ID = "ToDoItemCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        //Check if previously checked in previous app sessions
        if itemArray[indexPath.row].done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemArray[indexPath.row].done {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark}
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func addRowTableView() {
        //Update the table view
        let indexPath = IndexPath(row: itemArray.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func deleteItem(rowIndex: Int) {
        //Update the table view
        let indexPath = IndexPath(row: rowIndex, section: 0)
        context.delete(itemArray[rowIndex]) //Delete from database
        itemArray.remove(at: rowIndex) //Remove from itemArray
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        saveItems()
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New TodoeyItem", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What happens when the user clicks the Add Item button
            //Save item to DataModel
            let newItem : Item = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            self.saveItems()
            
            self.addRowTableView()
            
        }
        alert.addTextField { (alertTextField) in
            //Called when the text field is added as soon as the addButton in the navBar is pressed
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    
    //MARK: = Searchbar methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Query the DB to get the results the user is looking for
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //NSPredicate is a specification class for how data should be fetched
        request.predicate = NSPredicate(format: "title BEGINSWITH[cd] %@", searchBar.text!)
        //For all items in itemArray search for the ones whose title property begins with %@(whatever is typed in the searchbar)
        
        //Sorts our results from A-Z
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //Attempt to fecth from DB the results we've specified in our 'request'
        loadItems(with: request)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //If the searchbar is empty
            self.loadItems() //Show all existing items in table view
            tableView.reloadData()
            
            DispatchQueue.main.async { //To run this code on the main queue (in the foreground)
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}
