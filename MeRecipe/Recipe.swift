//
//  Recipe.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import Foundation

class Recipe {
    var name: String?
    var difficulty: String?
    var ingredients: String?
//    var ingredients: [String] = []
    
    init(name: String?, difficulty: String?, ingredients: String?) {
        self.name = name
        self.difficulty = difficulty
        self.ingredients = ingredients
    }
}
