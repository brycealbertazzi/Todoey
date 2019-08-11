//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/9/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    let ITEM_ARRAY_KEY: String = "ItemArrayKey"
    var itemArray: [Item] = [Item]()
    //userDomainMask is the user's home directory
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        //Load items from Items.plist
        loadItems()
    }
    
    //MARK: - Model Manipulation Methods
    func saveItems() {
        //Save itemArray into userdefaults
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array")
        }
    }
    
    func loadItems() {
        
        let data = try? Data(contentsOf: dataFilePath!)
        let decoder = PropertyListDecoder()
        do {
            itemArray = try decoder.decode([Item].self, from: data!)
        } catch {
            print("Error decoding item array")
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
        //Save done val to endocerData
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New TodoeyItem", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What happens when the user clicks the Add Item button
            let newItem : Item = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            let indexPath = IndexPath(row: self.itemArray.count - 1, section: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
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

