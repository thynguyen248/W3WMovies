//
//  DateExtension.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Foundation

enum AppDateTimeFormat: String {
    case normal = "yyyy-MM-dd"
    case short = "yyyy, dd MMMM"
}

extension Date {
    func toString(format: AppDateTimeFormat = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}

extension String {
    func toDate(format: AppDateTimeFormat = .normal) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: self)
    }
}
