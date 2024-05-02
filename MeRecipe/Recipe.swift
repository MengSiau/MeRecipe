//
//  Recipe.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import Foundation
import UIKit

class Recipe {
    var name: String?
    var description: String? 
    var prepTime: String?
    var cookTime: String?
    var difficulty: String?
    var image: UIImage?
    
    var ingredients: String? // [String] = [], perhaps string manipulation, but store string for now.
    var directions: String?
    
    var protein: String?
    var carbohydrate: String?
    var fats: String?
    var calories: String?

    
    init(name: String?, description: String?, prepTime: String?, cookTime: String?, difficulty: String?, image: UIImage?, ingredients: String?) {
        self.name = name
        self.description = description
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.difficulty = difficulty
        self.image = image
        
        self.ingredients = ingredients
    }
}
