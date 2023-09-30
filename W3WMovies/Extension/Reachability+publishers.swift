//
//  Reachability+publishers.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Reachability
import Combine
import Foundation

extension Reachability {
    var reachabilityChanged: AnyPublisher<Reachability, Never> {
        return NotificationCenter.default.publisher(for: Notification.Name.reachabilityChanged)
            .compactMap { $0.object as? Reachability }
            .eraseToAnyPublisher()
    }
    
    var status: AnyPublisher<Reachability.Connection, Never> {
        return reachabilityChanged
            .map { $0.connection }
            .eraseToAnyPublisher()
    }
    
    var isReachable: AnyPublisher<Bool, Never> {
        return reachabilityChanged
            .map { $0.connection != .unavailable }
            .eraseToAnyPublisher()
    }
    
    var isConnected: AnyPublisher<Void, Never> {
        return isReachable
            .filter { $0 }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var isDisconnected: AnyPublisher<Void, Never> {
        return isReachable
            .filter { !$0 }
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
