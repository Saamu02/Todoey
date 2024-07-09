//
//  Category.swift
//  Todoey
//
//  Created by Ussama Irfan on 09/07/2024.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    var items = List<Item>()
}
