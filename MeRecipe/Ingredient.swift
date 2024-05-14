//
//  Ingredient.swift
//  MeRecipe
//
//  Created by Meng Siau on 14/5/2024.
//

import FirebaseFirestoreSwift
import Foundation
import UIKit

class Ingredient: NSObject, Codable {
    @DocumentID var id: String?
    var name: String?
}

enum CodingKeysIngredient: String, CodingKey {
    case id
    case name
}
