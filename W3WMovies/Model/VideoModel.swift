//
//  VideoModel.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/30/23.
//

import Foundation

struct VideoResponseModel: Decodable {
    let results: [VideoModel]?
}

struct VideoModel: Decodable {
    let key: String?
}
