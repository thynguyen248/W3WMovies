//
//  ViewModelType.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

protocol Bindable: AnyObject {
    associatedtype ViewModelType
    var viewModel: ViewModelType { get set }
    func bindViewModel()
}
