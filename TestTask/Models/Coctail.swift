//
//  Coctail.swift
//  TestTask
//
//  Created by Дмитрий Болучевских on 01.04.2022.
//

import Foundation

struct Drinks: Codable {
    let drinks: [Coctail]
}

struct Coctail: Codable {
    let strDrink: String
    let strDrinkThumb: String
    let idDrink: String
}
