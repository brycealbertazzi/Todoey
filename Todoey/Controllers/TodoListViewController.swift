//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/9/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    let ITEM_ARRAY_KEY: String = "ItemArrayKey"
    var todoItems: Results<Item>?
    var selectedCategory : Category? {
        didSet{
            //What to do as soon as selectedCategory is given a value
            loadItems()
        }
    }//nil until we select a category in CategoryViewController
    
    //userDomainMask is the user's home directory
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        tableView.separatorStyle = .none
        
    }
    
    @IBOutlet weak var SearchBar: UISearchBar!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let colorHex = selectedCategory?.colorBG {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
            
            navBar.barTintColor = UIColor(hexString: colorHex)
            title = selectedCategory!.name
            SearchBar.barTintColor = UIColor(hexString: colorHex)
            navBar.tintColor = UIColor.flatWhite()
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.flatWhite()!]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let origionalColor = UIColor.flatGreen() else {
            fatalError()
        }
        navigationController?.navigationBar.barTintColor = origionalColor
    }
    
    
    //MARK: - Model Manipulation Methods
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //UIApplication.shared corresponds to the current app as an object
    
   func loadItems() {
    
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
    
     }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.textColor = UIColor.flatWhite()
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            let c = selectedCategory?.colorBG
            if let color = UIColor(hexString: c)?.darken(byPercentage: CGFloat(CGFloat(indexPath.row) / CGFloat(todoItems!.count)) / 2.5) {
                cell.backgroundColor = color
            }
            
            //Check if previously checked in previous app sessions
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if todoItems[indexPath.row].done {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark}
//
//        todoItems[indexPath.row].done = !itemArray[indexPath.row].done
        if let item = todoItems?[indexPath.row] {
            do {
            try realm.write {
                item.done = !item.done
            }
            } catch {
              print("Error saving done status \(error)")
            }
            tableView.reloadData()
            //tableView.cellForRow(at: indexPath)?.accessoryType = item.done ? .checkmark : .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Unable to delete item \(error)")
            }
        }
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New TodoeyItem", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What happens when the user clicks the Add Item button
            //Save item to DataModel
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                    self.loadItems()
                } catch {
                    print("Error saving items in category \(error)")
                }
                
            } else {
               print("Current category does not exist")
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            //Called when the text field is added as soon as the addButton in the navBar is pressed
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
extension TodoListViewController: UISearchBarDelegate {
    //MARK: Search Bar Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Update the todoItems to match the results specified by the predicate
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //If the searchbar is empty
            loadItems() //Show all existing items in table view
            tableView.reloadData()
            
            DispatchQueue.main.async { //To run this code on the main queue (in the foreground)
                searchBar.resignFirstResponder()
            }
        } else {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            
            tableView.reloadData()
        }
    }
}
