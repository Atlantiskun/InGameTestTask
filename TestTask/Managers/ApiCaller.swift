//
//  ApiCaller.swift
//  TestTask
//
//  Created by Дмитрий Болучевских on 01.04.2022.
//

import Foundation
import Alamofire

final class ApiCaller {
    static let shared = ApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://www.thecocktaildb.com/api/json/v1/1/filter.php" // ?a=Non_Alcoholic
    }
    
    public func getNonAlc(completion: @escaping (Result<Drinks, AFError>) -> Void) {
        let request = AF.request(Constants.baseAPIURL + "?a=Non_Alcoholic")
        request.responseDecodable(of: Drinks.self) { response in
            switch response.result {
            case .success(let model):
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
//    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
//        AuthManager.shared.withValidToken { token in
//            guard let apiURL = url else {
//                return
//            }
//            var request = URLRequest(url: apiURL)
//            request.setValue("Bearer \(token)",
//                             forHTTPHeaderField: "Authorization")
//            request.httpMethod = type.rawValue
//            request.timeoutInterval = 30
//            completion(request)
//        }
//    }
}
