//
//  ReusableCell.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/27/23.
//

import UIKit

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
