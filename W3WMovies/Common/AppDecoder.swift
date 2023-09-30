//
//  AppDecoder.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Foundation

final class AppDecoder {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = AppDateTimeFormat.normal.rawValue
            return formatter
        }()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}
