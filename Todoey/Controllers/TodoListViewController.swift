//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/9/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
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
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    
    //MARK: - Model Manipulation Methods
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //UIApplication.shared corresponds to the current app as an object
    
   func loadItems(/*with request: NSFetchRequest<Item> = /*Default Val*/ Item.fetchRequest(), predicate: NSPredicate? = nil*/) {
    
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    
/*****************************************************************************/
//        //Read data from database
//        do {
//            itemArray = try context.fetch(request) //Load itemArray with the contents from the request
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
///*****************************************************************************/
     }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    let CELL_ID = "ToDoItemCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
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
    
    func addRowTableView() {
        //Update the table view
        print(todoItems!.count)
        let indexPath = IndexPath(row: todoItems!.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func deleteItem(rowIndex: Int) {
        //Update the table view
        if let item = todoItems?[rowIndex] {
            do {
               try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Unable to delete item \(error)")
            }
        }
        
//        let indexPath = IndexPath(row: rowIndex, section: 0)
//        context.delete(itemArray[rowIndex]) //Delete from database
//        itemArray.remove(at: rowIndex) //Remove from itemArray
//        tableView.beginUpdates()
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//        tableView.endUpdates()
//
//        saveItems()
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
                } catch {
                    print("Error saving items in category \(error)")
                }
                
            } else {
               print("Current category does not exist")
            }
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
        
        //Update the todoItems to match the results specified by the predicate
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

/**************************************************/
//        //Query the DB to get the results the user is looking for
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        //NSPredicate is a specification class for how data should be fetched
//        request.predicate = NSPredicate(format: "title BEGINSWITH[cd] %@", searchBar.text!)
//        //For all items in itemArray search for the ones whose title property begins with %@(whatever is typed in the searchbar)
//
//        //Sorts our results from A-Z
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        //Attempt to fecth from DB the results we've specified in our 'request'
//loadItems(with: request, predicate: request.predicate!)
/**************************************************/
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
