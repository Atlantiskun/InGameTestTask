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
        static let baseAPIURL = "https://www.thecocktaildb.com/api/json/v1/1/filter.php"
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
}
