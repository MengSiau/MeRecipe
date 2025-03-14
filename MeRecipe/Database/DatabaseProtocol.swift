//
//  DatabaseProtocol.swift
//  MeRecipe
//
//  Created by Meng Siau on 4/5/2024.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case recipe
    case recipeList
    case ingredient // For now
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe])
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe])
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) 
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addRecipe(name: String?, desc: String?, prepTime: String?, cookTime: String?, difficulty: String?, imageData: Data?, ingredients: String?, directions: String?, protein: String?, carbohydrate: String?, fats: String?, calories: String?)
    func editRecipe(recipeToEdit: Recipe?, name: String?, desc: String?, prepTime: String?, cookTime: String?, difficulty: String?, imageData: Data?, ingredients: String?, directions: String?, protein: String?, carbohydrate: String?, fats: String?, calories: String?)
    func deleteRecipe(recipe: Recipe)
    func editRecipeCategory(recipeToEdit: Recipe?, category: String?)
    func editRecipeNotificationTime(recipeToEdit: Recipe?, notificationTime: String?)
    
    func addIngredient(name: String?)
    func deleteIngredient(ingredient: Ingredient)
    
    var defaultRecipeList: RecipeList {get}
    func addRecipeList(recipeListName: String) -> RecipeList
    func deleteRecipeList(recipeList: RecipeList)
    func addRecipeToRecipeList(recipe: Recipe, recipeList: RecipeList) -> Bool
    func removeRecipeFromRecipeList(recipe: Recipe, recipeList: RecipeList)
}


