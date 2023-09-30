//
//  DiffableCellItem.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/30/23.
//

import Foundation

protocol DiffableItem: Hashable {
    var identifier: String { get }
}

extension DiffableItem {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: any DiffableItem, rhs: any DiffableItem) -> Bool {
      lhs.identifier == rhs.identifier
    }
}
