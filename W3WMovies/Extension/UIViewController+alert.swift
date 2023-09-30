//
//  UIViewController+alert.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/27/23.
//

import UIKit

extension UIViewController {
    func showAlerWithMessage(_ message: String, _ completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            completion?()
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
