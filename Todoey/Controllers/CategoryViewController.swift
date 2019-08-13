//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/12/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories: [Category] = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //UIApplication.shared corresponds to the current app as an object
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }

    // MARK: - Table view data source method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    let CATEGORY_CELL_KEY: String = "CategoryCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CATEGORY_CELL_KEY, for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    let CATEGORY_ITEMS_KEY: String = "goToItems"
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Go the the corresponding ToDo List
        performSegue(withIdentifier: CATEGORY_ITEMS_KEY, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Load items in the selected category
        let destinationVC = segue.destination as! TodoListViewController
        
        //Get the category which corresponds to the selected cell
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK: - TableView Manupulation Methods, CRUD
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving categories \(error)")
        }
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add category", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            self.categories.append(newCategory)
            self.saveCategories()
            
            //Update the table view
            self.tableView.beginUpdates()
            let indexPath = IndexPath(row: self.categories.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }))
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    

}
