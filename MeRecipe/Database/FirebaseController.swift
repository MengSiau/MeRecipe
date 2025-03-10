//
//  FirebaseController.swift
//  MeRecipe
//
//  Created by Meng Siau on 4/5/2024.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    let DEFAULT_RECIPELIST_NAME = "Default Recipe List"
    var listeners = MulticastDelegate<DatabaseListener>()
    var listOfRecipe: [Recipe]
    var defaultRecipeList: RecipeList
    
    var listOfIngredient: [Ingredient]
    
    // References to Firebase and its collections
    var authController: Auth
    var database: Firestore
    var recipeRef: CollectionReference?
    var recipeListRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    var ingredientRef: CollectionReference?
    

    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        listOfRecipe = [Recipe]()
        defaultRecipeList = RecipeList()
        
        listOfIngredient = [Ingredient]()
        
        super.init()
        
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
            }
            catch {
                fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
            }
            self.setupRecipeListener()
            self.setupIngredientListener()
        }
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
        
        if listener.listenerType == .ingredient || listener.listenerType == .all {
            listener.onAllIngredientChange(change: .update, ingredients: listOfIngredient)
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func editRecipeCategory(recipeToEdit: Recipe?, category: String?) {
        guard let recipeToEdit = recipeToEdit, let recipeToEditId = recipeToEdit.id else {
            print("Unable to unwrap recipeToEdit")
            return
        }
        
        recipeToEdit.category = category
        
        do {
            try recipeRef?.document(recipeToEditId).setData(from: recipeToEdit, merge: true)
            print("recipe setData called")
        } catch {
            print("Failed to update Recipe")
            return
        }
    }
    
    func editRecipeNotificationTime(recipeToEdit: Recipe?, notificationTime: String?) {
        guard let recipeToEdit = recipeToEdit, let recipeToEditId = recipeToEdit.id else {
            print("Unable to unwrap recipeToEdit")
            return
        }
        
        recipeToEdit.notificationTime = notificationTime
        
        do {
            try recipeRef?.document(recipeToEditId).setData(from: recipeToEdit, merge: true)
            print("recipe setData called")
        } catch {
            print("Failed to update Recipe")
            return
        }
    }
    
    func editRecipe(recipeToEdit: Recipe?, name: String?, desc: String?, prepTime: String?, cookTime: String?, difficulty: String?, imageData: Data?, ingredients: String?, directions: String?, protein: String?, carbohydrate: String?, fats: String?, calories: String?) {
        
        guard let recipeToEdit = recipeToEdit, let recipeToEditId = recipeToEdit.id else {
            print("Unable to unwrap recipeToEdit")
            return
        }
        
        let storageReference = Storage.storage().reference()
        guard let imageData = imageData else {
            print("Cannot unwrap image data")
            return
        }
        
        recipeToEdit.name = name
        recipeToEdit.desc = desc
        recipeToEdit.prepTime = prepTime
        recipeToEdit.cookTime = cookTime
        recipeToEdit.difficulty = difficulty
        
        recipeToEdit.ingredients = ingredients
        recipeToEdit.directions = directions
        
        recipeToEdit.protein = protein
        recipeToEdit.carbohydrate = carbohydrate
        recipeToEdit.fats = fats
        recipeToEdit.calories = calories
        
        // Store updated Recipe on firebase //
        do {
            try recipeRef?.document(recipeToEditId).setData(from: recipeToEdit)
            print("recipe setData called")
        } catch {
            print("Failed to update Recipe")
            return
        }
        
        // Storing of Recipe Image //
        let timestamp = UInt(Date().timeIntervalSince1970)
        let filename = "\(timestamp).jpg"
        let imageRef = storageReference.child("\(timestamp)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        let uploadTask = imageRef.putData(imageData, metadata: metadata)
        
        guard let recipeToEditID = recipeToEdit.id else {
            print("cannot unwrap recipe id")
            return
        }
        
        // Attempt to save image URL in firebase //
        uploadTask.observe(.success) { snapshot in
            self.recipeRef?.document(recipeToEditID).updateData(["url" : "\(imageRef)"])
            self.recipeRef?.document(recipeToEditID).updateData(["imageFileName" : "\(filename)"])
            print(imageRef)
        }
        uploadTask.observe(.failure) { snapshot in
            print("FAIL UPLOAD IMAGE")
        }
        
        // Save image locally //
        saveImageData(filename: filename, imageData: imageData)
    }
    
    func addRecipe(name: String?, desc: String?, prepTime: String?, cookTime: String?, difficulty: String?, imageData: Data?, ingredients: String?, directions: String?, protein: String?, carbohydrate: String?, fats: String?, calories: String?) {
        
        // Attempet to unwrap image data //
        let storageReference = Storage.storage().reference()
        guard let imageData = imageData else {
            print("FirebaseCont: Cannot unwrap image data")
            return
        }
        
        // Create a Recipe object and store basic values //
        let recipe = Recipe()
        recipe.name = name
        recipe.desc = desc
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        recipe.difficulty = difficulty
        
        recipe.ingredients = ingredients
        recipe.directions = directions
        
        recipe.protein = protein
        recipe.carbohydrate = carbohydrate
        recipe.fats = fats
        recipe.calories = calories
        
        recipe.category = ""
        recipe.notificationTime = ""
        
        
        // Storing of Recipe Image //
        let timestamp = UInt(Date().timeIntervalSince1970)
        let filename = "\(timestamp).jpg"
        let imageRef = storageReference.child("\(timestamp)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        let _ = imageRef.putData(imageData, metadata: metadata)
        
        recipe.url = imageRef.bucket
        recipe.imageFileName = filename
        
        // Store newly created Recipe on firebase //
        do {
            if let recipeRef = try recipeRef?.addDocument(from: recipe) {
                recipe.id = recipeRef.documentID 
            }
        } catch {
            print("FirebaseCont: Failed to serialize Reicpe")
        }
        
        
        // Save image locally //
        saveImageData(filename: filename, imageData: imageData)
        
        print("FirebaseCont addRecipe method called")
        return
    }
    
    
    // Function used in addRecipe() to locally store image data as a file //
    func saveImageData(filename: String, imageData: Data) {
        print("\(filename) saved locally")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }
    }
    
    func deleteRecipe(recipe: Recipe) {
        if let recipeID = recipe.id {
            recipeRef?.document(recipeID).delete()
        }
    }
    
    // FOR INGREDIENTS //
    
    func addIngredient(name: String?) {
        let ingredient = Ingredient()
        ingredient.name = name
        
        // Store newly created Recipe on firebase //
        do {
            if let ingredientRef = try ingredientRef?.addDocument(from: ingredient) {
                ingredient.id = ingredientRef.documentID // returns id if added successfully
            }
        } catch {
            print("Failed to serialize Reicpe")
        }
    }
    
    func deleteIngredient(ingredient: Ingredient) {
        if let ingredientID = ingredient.id {
            ingredientRef?.document(ingredientID).delete()
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
      
                recipeListRef?.document(recipeListID).updateData(["recipes": FieldValue.arrayRemove([removeRecipeRef])])
            }
        }
    }
    
    // MARK: - Firebase Controller Specific methods
    
    func getRecipeById(_ id: String) -> Recipe? {
        for recipe in listOfRecipe {
            if recipe.id == id { return recipe }
        }
        return nil
    }
    
    // Listens to ALL changes in the RecipeList collection | Use Snapshot
    func setupRecipeListener() {
        recipeRef = database.collection("RecipeList")
        
        // Closure executes whenever change occur in RecipeList collection
        recipeRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseRecipeSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupIngredientListener() {
        ingredientRef = database.collection("IngredientList")
        
        // Closure executes whenever change occur in RecipeList collection
        ingredientRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseIngredientSnapshot(snapshot: querySnapshot)
        }
    }
    

    
    func parseRecipeSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in // iterate thro each document change in snapshot
            var recipe: Recipe
            // Try decode document data as Recipe object so we can do logic stuff to it
            do {
                recipe = try change.document.data(as: Recipe.self)
            } catch {
                fatalError("Unable to decode recipe: \(error.localizedDescription)")
            }
            
            // Respond to the types of changes made to recipe accordingly
            if change.type == .added {
                listOfRecipe.insert(recipe, at: Int(change.newIndex)) // The local array in this file
            } else if change.type == .modified {
                listOfRecipe.remove(at: Int(change.oldIndex))
                listOfRecipe.insert(recipe, at: Int(change.newIndex))
            } else if change.type == .removed {
                listOfRecipe.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.recipe || listener.listenerType == ListenerType.all {
                listener.onAllRecipeChange(change: .update, recipes: listOfRecipe)
            }
        }
    }
    
    func parseIngredientSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in // iterate thro each document change in snapshot
            var ingredient: Ingredient
            // Try decode document data as Recipe object so we can do logic stuff to it
            do {
                ingredient = try change.document.data(as: Ingredient.self)
            } catch {
                fatalError("Unable to decode ingredient: \(error.localizedDescription)")
            }
            
            // Respond to the types of changes made to recipe accordingly
            if change.type == .added {
                listOfIngredient.insert(ingredient, at: Int(change.newIndex)) // The local array in this file
            } else if change.type == .modified {
                listOfIngredient.remove(at: Int(change.oldIndex))
                listOfIngredient.insert(ingredient, at: Int(change.newIndex))
            } else if change.type == .removed {
                listOfIngredient.remove(at: Int(change.oldIndex))
            }
        }
        
        // Call the multicast delegate
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.ingredient || listener.listenerType == ListenerType.all {
                listener.onAllIngredientChange(change: .update, ingredients: listOfIngredient)
            }
        }
        
    }
    
}
