//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Ussama Irfan on 04/07/2024.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navBarColor = UIColor(hexString: selectedCategory?.backgroundColor ?? "1D9BF6") ?? UIColor.clear
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navBarColor
        

        let titleColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        title = selectedCategory?.name ?? "Items"
        
        let titleAttribute = [
            NSAttributedString.Key.foregroundColor: titleColor
        ]
        
        appearance.titleTextAttributes = titleAttribute
        appearance.largeTitleTextAttributes = titleAttribute

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        navigationController?.navigationBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        addButton.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
        searchBar.searchTextField.clearButtonMode = .always
        
        searchBar.barTintColor = navBarColor
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.tintColor = .black
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.searchTextField.textColor = .black
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField , let clearButton = searchTextField.value(forKey: "_clearButton")as? UIButton {

            if let image = clearButton.image(for: .highlighted) {
                clearButton.isHidden = false
                let tintedClearImage = image.withTintColor(.black)
                clearButton.setImage(tintedClearImage, for: .normal)
                clearButton.setImage(tintedClearImage, for: .highlighted)
                
            } else {
               clearButton.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
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
        
        let percentage = CGFloat(indexPath.row) / CGFloat(todoItems?.count ?? 1)
        
        let colorForGradient = UIColor(hexString: selectedCategory?.backgroundColor ?? "1D9BF6") ?? UIColor.clear
        
        let backgroundColor = colorForGradient.darken(byPercentage: percentage)
        cell.backgroundColor = backgroundColor
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor!, returnFlat: true)
        
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
