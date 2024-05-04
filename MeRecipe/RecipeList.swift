//
//  RecipeList.swift
//  MeRecipe
//
//  Created by Meng Siau on 4/5/2024.
//

import UIKit

class RecipeList: NSObject, Codable {
    
    var id: String?
    var name: String?
    var recipes: [Recipe] = []
}
