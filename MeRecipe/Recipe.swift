//
//  Recipe.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import FirebaseFirestoreSwift
import Foundation
import UIKit

class Recipe: NSObject, Codable {
    @DocumentID var id: String?
    
    var name: String?
    var desc: String?
    var prepTime: String?
    var cookTime: String?
    var difficulty: String?
    var image: Data?
    var url: String? 
    var imageFileName: String?
    
    var ingredients: String?
    var directions: String?
    
    var protein: String?
    var carbohydrate: String?
    var fats: String?
    var calories: String?
    
    var category: String?
    var notificationTime: String?
}

enum CodingKeys: String, CodingKey {
    case id
    case desc
    case prepTime
    case cookTime
    case difficulty
    case image
    
    case ingredients
    case directions
    
    case protein
    case carbohydrates
    case fats
    case calories
    
    case category
    case notificationTime
}


