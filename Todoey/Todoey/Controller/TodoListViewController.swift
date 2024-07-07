//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Ussama Irfan on 04/07/2024.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first?.appendingPathComponent("Items.plist")
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoListItemCell")
                
        loadItems()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add todoey Ttem", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action  in
            
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
                        
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.filePath!)
            
        } catch {
            print("Error encoding item array, " + error.localizedDescription )
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        let decoder = PropertyListDecoder()
        
        if let data = try? Data(contentsOf: self.filePath!) {
            
            do {
                self.itemArray = try decoder.decode([Item].self, from: data)
                
            } catch {
                print("Error decoding item array, " + error.localizedDescription )
            }
        }
    }
}

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done.toggle()
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
