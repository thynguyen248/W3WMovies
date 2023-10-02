//
//  APIClient.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import Combine
import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Request {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: String { get }
    var queryParams: [String: Any]? { get }
    var body: [String: Any]? { get }
    var headers: [String: String]? { get }
    associatedtype ReturnType: Decodable
}

extension Request {
    var baseURL: String { return APIConstants.baseURL }
    var method: HTTPMethod { return .get }
    var contentType: String { return "application/json" }
    var queryParams: [String: Any]? { return nil }
    var body: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }
    
    private func requestBodyFrom(params: [String: Any]?) -> Data? {
        guard let params = params else { return nil }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }
        return httpBody
    }
    
    var urlRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.path = "\(urlComponents.path)\(path)"
        
        var queryDic: [String: Any] = queryParams ?? [:]
        queryDic["api_key"] = APIConstants.key
        let queryItems = queryDic.map {
            return URLQueryItem(name: "\($0)", value: "\($1)")
        }
        urlComponents.queryItems = queryItems
        
        guard let finalURL = urlComponents.url else { return nil }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)
        request.allHTTPHeaderFields = headers
        return request
    }
}

struct APIConstants {
    static let baseURL = "https://api.themoviedb.org/3"
    static let key = "7a20b718d2507f11dad2d84d6b028fdd"
    static let posterURL = "https://image.tmdb.org/t/p/w500/%@"
    static let videoThumbnailURL = "https://img.youtube.com/vi/%@/hqdefault.jpg"
}

protocol APIClientInterface {
    func getMovieList(page: Int) -> AnyPublisher<MovieResponseModel, AppError>
    func getMovieDetail(movieId: Int) -> AnyPublisher<MovieModel, AppError>
    func searchMovies(keyword: String, page: Int) -> AnyPublisher<MovieResponseModel, AppError>
}

final class APIClient: APIClientInterface {
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    
    init(urlSession: URLSession = URLSession.shared,
         decoder: JSONDecoder = AppDecoder.decoder) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
    
    func request<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, AppError> {
        guard let urlRequest = request.urlRequest else {
            return Fail(outputType: R.ReturnType.self, failure: AppError.invalidRequest).eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) in
                if let response = response as? HTTPURLResponse,
                   !((200...299).contains(response.statusCode)) {
                    throw AppError(statusCode: response.statusCode)
                }
                
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
                let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
                print("Response:\n===============\n\(jsonString)\n===============")
                
                return data
            }
            .decode(type: R.ReturnType.self, decoder: decoder)
            .mapError({ [weak self] error in
                print((error as NSError).debugDescription)
                return self?.handleError(error) ?? AppError.unknownError
            })
            .eraseToAnyPublisher()
    }
    
    private func handleError(_ error: Error) -> AppError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError(error.localizedDescription)
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as AppError:
            return error
        default:
            return .unknownError
        }
    }
}
