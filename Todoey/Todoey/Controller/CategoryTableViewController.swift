//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Ussama Irfan on 09/07/2024.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navBarColor = UIColor(hexString: "1D9BF6")!
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navBarColor
        

        let titleAttribute = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        appearance.titleTextAttributes = titleAttribute
        appearance.largeTitleTextAttributes = titleAttribute

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.backgroundColor = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
            
        } catch {
            print("Error saving data to realm, " + error.localizedDescription )
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        guard let categories else { return }
        
        do {
            
            try self.realm.write {
                self.realm.delete(categories[indexPath.row])
            }
            
        } catch {
            print("Error deleting data from realm, " + error.localizedDescription )
        }
    }
}

extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categories?[indexPath.row]
        
        cell.textLabel?.text = category?.name
        
        let backgroundColor = UIColor(hexString: category?.backgroundColor ?? "1D9BF6")
        
        cell.backgroundColor = backgroundColor
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor!, returnFlat: true)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
}
