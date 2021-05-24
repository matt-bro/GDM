//
//  GenericDataSource.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import Foundation
import UIKit

///A generic datasource for tableeviews
class GenericDataSource<CELL: UITableViewCell, T> : NSObject, UITableViewDataSource {

    private var cellIdentifier: String!
    var items: [T]!
    var configureCell: (CELL, T) -> Void = {_, _ in }

    init(cellIdentifier: String, items: [T], configureCell : @escaping (CELL, T) -> Void) {
        self.cellIdentifier = cellIdentifier
        self.items =  items
        self.configureCell = configureCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CELL
        let item = self.items[indexPath.row]
        self.configureCell(cell, item)
        return cell
    }
}
