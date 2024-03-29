//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/12/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //UIApplication.shared corresponds to the current app as an object
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
        
    }

    // MARK: - Table view data source method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.textColor = UIColor.flatWhite()
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].colorBG)
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    let CATEGORY_ITEMS_KEY: String = "goToItems"
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Go the the corresponding ToDo List
        performSegue(withIdentifier: CATEGORY_ITEMS_KEY, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Load items in the selected category
        let destinationVC = segue.destination as! TodoListViewController
        //Get the category which corresponds to the selected cell
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        } else {
            print("Could not get index path for selected category row")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }
    
    //MARK: - TableView Manupulation Methods, CRUD
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categories \(error)")
        }
    }
    
    func loadCategories() {

        //Sets categories array to an List of all category ojects saved in Realm
        categories = realm.objects(Category.self).sorted(byKeyPath: "dateCreated", ascending: false)
        //Don't need to append to categories when add button its pressed b/c Results<> autoupdates
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add category", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.dateCreated = Date()
            if let newColor = UIColor.randomFlat()?.hexValue() {
                newCategory.colorBG = newColor
            } else {newCategory.colorBG = "#95A4A5"}
            //self.categories.append(newCategory)
            self.save(category: newCategory)
            
            
            //Update the table view
            self.tableView.reloadData()
        }))
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

