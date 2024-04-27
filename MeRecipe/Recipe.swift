//
//  Recipe.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import Foundation

class Recipe {
    var name: String?
    var difficulty: Int?
//    var time: Int?
//    var ingredients: [String] = []
    
    init(name: String?, difficulty: Int?) {
        self.name = name
        self.difficulty = difficulty
    }
}
