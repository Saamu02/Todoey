//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Ussama Irfan on 04/07/2024.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var todoItems: Results<Item>?
        
    var selectedCategory : Category? {
        
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        loadItems()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add todoey Ttem", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action  in
                 
            guard let currentCategory = self.selectedCategory else { return }
            
            do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    
                    currentCategory.items.append(newItem)

                    self.realm.add(newItem)
                }
                
            } catch {
                print("Error saving data to realm, " + error.localizedDescription )
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
                        
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        guard let todoItems else { return }
        
        do {
            
            try self.realm.write {
                self.realm.delete(todoItems[indexPath.row])
            }
            
        } catch {
            print("Error deleting data from realm, " + error.localizedDescription )
        }
    }
}

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = todoItems?[indexPath.row]
        
        cell.textLabel?.text = item?.title
        cell.accessoryType = (item?.done ?? false) ? .checkmark : .none
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do {
                try realm.write {
                    item.done.toggle()
                }
                
            } catch {
                print("Error saving data to realm, " + error.localizedDescription )
            }
        }
                
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text!.isEmpty {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
