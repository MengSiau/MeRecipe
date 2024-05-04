//
//  FirebaseController.swift
//  MeRecipe
//
//  Created by Meng Siau on 4/5/2024.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    let DEFAULT_RECIPELIST_NAME = "Default Recipe List"
    var listeners = MulticastDelegate<DatabaseListener>()
    var listOfRecipe: [Recipe]
    var defaultRecipeList: RecipeList
    
    // References to Firebase and its collections
    var authController: Auth
    var database: Firestore
    var recipeRef: CollectionReference?
    var recipeListRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        recipeList = [Recipe]()
        defaultRecipeList = RecipeList()
        super.init()
    }
    
    func cleanup() {} // leave empty
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .recipe || listener.listenerType == .all {
            listener.onAllRecipeChange(change: .update, recipes: listOfRecipe)
        }
        
        if listener.listenerType == .recipeList || listener.listenerType == .all {
            listener.onRecipeListChange(change: .update, recipes: defaultRecipeList.recipes)
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addRecipe(name: String?, desc: String?, prepTime: String?, cookTime: String?, difficulty: String?, image: Data?, ingredients: String?) -> Recipe {
        let recipe = Recipe()
        recipe.name = name
        recipe.desc = desc
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        recipe.difficulty = difficulty
        recipe.image = image
        
        recipe.ingredients = ingredients
        
        do {
            if let recipeRef = try recipeRef?.addDocument(from: recipe) {
                recipe.id = recipeRef.documentID // returns id if added successfully -> use this id to update/delete
            }
        } catch {
            print("Failed to serialize Reicpe")
        }
        return recipe
    }
    
    func deleteRecipe(recipe: Recipe) {
        if let recipeID = recipe.id {
            recipeRef?.document(recipeID).delete()
        }
    }
    
    func addRecipeList(recipeListName: String) -> RecipeList {
        let recipeList = RecipeList()
        recipeList.name = recipeListName
        if let recipeListRef = recipeListRef?.addDocument(data: ["name" : recipeListName]) {
            recipeList.id = recipeListRef.documentID
        }
        return recipeList
    }
    
    func deleteRecipeList(recipeList: RecipeList) {
        if let recipeListID = recipeList.id {
            recipeListRef?.document(recipeListID).delete()
        }
    }
    
    func addRecipeToRecipeList(recipe: Recipe, recipeList: RecipeList) -> Bool {
        guard let recipeID = recipe.id, let recipeListID = recipeList.id else {
            return false
        }
        
        if let newRecipeRef = recipeRef?.document(recipeID) {
            recipeListRef?.document(recipeListID).updateData(
                ["recipes" : FieldValue.arrayUnion([newRecipeRef])] // arrayUnion allow for adding number of new element to array in firestore
            )
        }
        return true
    }
    
    func removeRecipeFromRecipeList(recipe: Recipe, recipeList: RecipeList) {
        // Check if recipeList contains recipe + validate the documentID
        if recipeList.recipes.contains(recipe), let recipeListID = recipeList.id, let recipeID = recipe.id {
            if let removeRecipeRef = recipeRef?.document(recipeID) {
                // Update the heroes array in teams to remove the target hero by its reference
                recipeListRef?.document(recipeListID).updateData(["recipes": FieldValue.arrayRemove([removeRecipeRef])])
            }
        }
    }
    
    // MARK: - Firebase Controller Specific m=Methods
    
    
}
