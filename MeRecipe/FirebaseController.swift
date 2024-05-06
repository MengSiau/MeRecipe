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
        listOfRecipe = [Recipe]()
        defaultRecipeList = RecipeList()
        
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
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addRecipe(name: String?, desc: String?, prepTime: String?, cookTime: String?, difficulty: String?, imageData: Data?, ingredients: String?) {
        
        let storageReference = Storage.storage().reference()
        guard let imageData = imageData else {
            print("Cannot unwrap image data")
            return
        }
        
        let recipe = Recipe()
        recipe.name = name
        recipe.desc = desc
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        recipe.difficulty = difficulty
        //recipe.image = image
        
        recipe.ingredients = ingredients
        
        do {
            if let recipeRef = try recipeRef?.addDocument(from: recipe) {
                recipe.id = recipeRef.documentID // returns id if added successfully -> use this id to update/delete
            }
        } catch {
            print("Failed to serialize Reicpe")
        }
        
        
        // IMAGE //
        let timestamp = UInt(Date().timeIntervalSince1970)
//        let filename = "\(timestamp).jpg"
        let imageRef = storageReference.child("\(timestamp)")
        
        
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        let uploadTask = imageRef.putData(imageData, metadata: metadata)
        
        guard let recipeID = recipe.id else {
            print("cannot unwrap recipe id")
            return
        }
        
        uploadTask.observe(.success) { snapshot in
            self.recipeRef?.document(recipeID).updateData(["url" : "\(imageRef)"])
            print(imageRef)
        }
        uploadTask.observe(.failure) { snapshot in
            print("FAILLLLL UPLOAD IMAGE")
        }
        
        print("FirebaseCont addRecipe method called")
        return
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
//            if self.recipeListRef == nil { self.setupRecipeListListener()} // If first time called, set up listener
        }
    }
    
//    func setupRecipeListListener() {
//        recipeListRef = database.collection("PLACEHOLDER") // may not use, use this name as a placeholder
//        recipeListRef?.whereField("name", isEqualTo: DEFAULT_RECIPELIST_NAME).addSnapshotListener { (querySnapshot, error) in // specify name
//            guard let querySnapshot = querySnapshot, let recipeListSnapshot = querySnapshot.documents.first else { // validate snapshot
//                print("Error fetching RecipeList: \(error!)")
//                return
//            }
//            self.parseRecipeListSnapshot(snapshot: recipeListSnapshot)
//        }
//    }
    
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
        
        // Call the multicast delegate to call the onAllHeroChange on all listeners
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.recipe || listener.listenerType == ListenerType.all {
                listener.onAllRecipeChange(change: .update, recipes: listOfRecipe)
            }
        }
    }
    
//    func parseRecipeListSnapshot(snapshot: QueryDocumentSnapshot) {
//        
//        defaultRecipeList = RecipeList()
//        defaultRecipeList.name = snapshot.data()["name"] as? String
//        defaultRecipeList.id = snapshot.documentID
//        
//        // Try access the array of document references
//        if let recipeReference = snapshot.data()["recipes"] as? [DocumentReference] {
//            for reference in recipeReference { // Iterate through references, use it to get a hero, add hero to Team's array
//                if let recipe = getRecipeById(reference.documentID) {
//                    defaultRecipeList.recipes.append(recipe)
//                }
//            }
//        }
//        // Call Multicast delegate to invoke method to update all listeners
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.recipeList || listener.listenerType == ListenerType.all {
//                listener.onRecipeListChange(change: .update, recipes: defaultRecipeList.recipes)
//            }
//        }
//    }
    
}
