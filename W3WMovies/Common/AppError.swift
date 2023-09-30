//
//  AppError.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/27/23.
//

import Foundation

enum AppError: LocalizedError, Equatable {
    case invalidRequest
    case serverError
    case decodingError(_ message: String)
    case urlSessionFailed(_ error: URLError)
    case dbFetchError(_ message: String)
    case dbInsertError(_ message: String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest: return "Invalid request"
        case .serverError: return "Server error"
        case .decodingError(let message): return message
        case .urlSessionFailed(let error): return error.localizedDescription
        case .dbFetchError(let message): return message
        case .dbInsertError(let message): return message
        case .unknownError: return "Unknown error"
        }
    }
}

extension AppError {
    init(statusCode: Int) {
        switch statusCode {
        case 400...499: self = .invalidRequest
        case 500...599: self = .serverError
        default: self = .unknownError
        }
    }
}
