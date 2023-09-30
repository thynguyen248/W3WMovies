//
//  UINavigationController+theme.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import UIKit

extension UINavigationController {
    public func configDefaultBarStyle(tintColor: UIColor = .black) {
        navigationBar.tintColor = tintColor
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationBar.topItem?.backBarButtonItem = backButton
    }
}
