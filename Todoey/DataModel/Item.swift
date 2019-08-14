//
//  Item.swift
//  Todoey
//
//  Created by Bryce Albertazzi on 8/12/19.
//  Copyright © 2019 Bryce Albertazzi. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated : Date?
    
    //Variable to define the inverses relationship b/w item & category
    var parentCategory = LinkingObjects<Category>(fromType: Category.self, property: "items")
}
