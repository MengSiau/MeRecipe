//
//  MyRecipeCollectionViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import UIKit
import Firebase
import FirebaseStorage

class MyRecipeCollectionViewController: UICollectionViewController, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout, AddRecipeDelegate, DatabaseListener {
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        
    }
    
        
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
//    var storageReference = Storage.storage().reference()
    var recipeRef: CollectionReference?
    let storage = Storage.storage()
//    let cache = NSCache<NSString, UIImage>()
    
    
    let CELL_IMAGE = "imageCell"
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var listOfRecipe: [Recipe] = []
    var filteredListOfRecipe: [Recipe] = []
    weak var recipeDelegate: AddRecipeDelegate?
    
    let bottomToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    func addRecipe(_ newRecipe: Recipe) -> Bool {
        listOfRecipe.append(newRecipe)
        print("added")
        collectionView.reloadData();
        return true
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        collectionView.backgroundColor = .systemBackground
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // TEST
        generateTestRecipe()
        
        // Landing page - Ensure appearance is updated on app start up //
        let isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        setDarkMode(isDarkModeEnabled)
        
        // SEARCH BAR //
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Recipes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        filteredListOfRecipe = listOfRecipe
        
        navigationItem.hidesBackButton = true
        
        // TOOL BAR //
//        let homeBtn = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(homeButtonTapped))
        let shoppingListBtn = UIBarButtonItem(image: UIImage(systemName: "cart"), style: .plain, target: self, action: #selector(shoppingListBtnTapped))
        let mealScheduleBtn = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(mealScheduleBtnTapped))
        let settingsBtn = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        // Set the toolbar items
        self.toolbarItems = [shoppingListBtn, flexibleSpace, mealScheduleBtn, flexibleSpace, settingsBtn]
//        self.toolbarItems = [homeBtn, flexibleSpace, shoppingListBtn, flexibleSpace, mealScheduleBtn, flexibleSpace, settingsBtn]
    }
    
    // Action functions for bot nav bar //
    @objc func homeButtonTapped() {}
    @objc func shoppingListBtnTapped() {performSegue(withIdentifier: "shoppingListSegue", sender: self)}
    @objc func mealScheduleBtnTapped() {performSegue(withIdentifier: "mealSchedulerSegue", sender: self)}
    @objc func settingsButtonTapped() {performSegue(withIdentifier: "settingsSegue", sender: self)}
    
    private func setDarkMode(_ isDarkMode: Bool) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.toggleDarkMode(isDarkMode)
        }
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredListOfRecipe = listOfRecipe.filter({ (recipe: Recipe) -> Bool in
                return (recipe.name?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredListOfRecipe = listOfRecipe
        }
//        print(filteredListOfRecipe)
        collectionView.reloadData()
    }
    
    
    // name: String?, description: String?, prepTime: String?, cookTime: String?, difficulty: String?, ingredients: String?)
    func generateTestRecipe() {
//        listOfRecipe.append(Recipe(name: "Apple Pie",  description: "sweet apple pie!", prepTime: "20", cookTime: "40", difficulty: "3", ingredients: "30g Apple, 40g Sugar, 500mL milk"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        // Disable bot nav bar: Some screens will not have the bot nav bar //
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        
        // Enable bot nav bar //
        self.navigationController?.isToolbarHidden = true
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
        updateSearchResults(for: navigationItem.searchController!)
//        collectionView.reloadData();
    }

    // MARK: UICollectionViewDataSource

    // Set to 20
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return filteredListOfRecipe.count
    }

    // Function for getting Recipe Image that may have been stored locally //
    func loadImageFromLocal(filename: String) -> UIImage? {
        // Get the document directory path
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        // Create a file URL for the image
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        // Load image from file URL
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image from local storage: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Attempts to send a request to see if there is an internet connection //
    func checkInternetConnection() {
        let url = URL(string: "https://www.google.com")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, error == nil {
                let _ = data
            } else {
                DispatchQueue.main.async {
                    self.displayMessage(title: "No Internet Connection", message: "Recipe on this page may be out of sync. Please reconnect to the internet")
                }
            }
        }
        task.resume()
    }
    
    // Responsible for the creation/customization of the CollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IMAGE, for: indexPath) as! MyRecipeCollectionViewCell
        
        let currentRecipe = filteredListOfRecipe[indexPath.row]
        cell.backgroundColor = .secondarySystemFill
        
        // Set the cell Name //
        cell.recipeName.text = currentRecipe.name
        
        checkInternetConnection()
        
        // Get recipe image URL //
        guard let url = currentRecipe.url else{
            print("cannot unwrwap image url for cell")
            return cell
        }
        
        // Get Recipe's image file name and attempt to load it locally from files //
        guard let filename = currentRecipe.imageFileName else {
            print("cannot unwrap image file name locally")
            return cell
        }
        if let localImage = loadImageFromLocal(filename: filename) {
            cell.imageView.image = localImage
            return cell
        }
        
        // If image not locally stored, attempt to retrieve image from cloud //
        let storageReference = storage.reference(forURL: url)
        let cellIndex = indexPath.row // Capture the current index path
            
        let downloadTask = storageReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
            guard let imageData = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                self.displayMessage(title: "Connection error", message: "Error syncing recipes. Please connect to the internet. ")
                return
            }
            
            // Make sure that reused cells do not show images that are still previously being loaded in
            if let image = UIImage(data: imageData), indexPath.row == cellIndex {
                DispatchQueue.main.async {
                    print("updating image view")
                    cell.imageView.image = image
                }
            } else {
                print("Cell has been reused, skipping image update")
            }
        }
        
        cell.onReuse = {
            downloadTask.cancel()
        }
        
        return cell
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let imageItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        
        let imageItem = NSCollectionLayoutItem(layoutSize: imageItemSize)
        imageItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let imageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3))
        
        let imageGroup = NSCollectionLayoutGroup.horizontal(layoutSize: imageGroupSize, subitems: [imageItem])
        
        let imageSection = NSCollectionLayoutSection(group: imageGroup)
        
        return UICollectionViewCompositionalLayout(section: imageSection)
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "createRecipeSegue" {
//            if let cell = sender as? UICollectionViewCell, let indexPath = self.collectionView(UICollectionView, cellForItemAt: IndexPath) {
//                let destination = segue.destination as! ViewRecipeDetailViewController
//            }
//            
//        }
//    }
    
    // Prepares the Recipe values for the ViewReciipeDetail page //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRecipeSegue" {
            let destination = segue.destination as! CreateRecipeViewController
            destination.recipeDelegate = self // TODO: NEED THIS HERE?
            destination.mode = "create"
            
            
        } else if segue.identifier == "recipeDetailSegue" {
            if let selectedIndexPaths = collectionView.indexPathsForSelectedItems, let indexPath = selectedIndexPaths.first {
                let destination = segue.destination as! ViewRecipeDetailViewController
                let selectedRecipe = listOfRecipe[indexPath.row]
                
                guard let recipeImageFileName = selectedRecipe.imageFileName else {
                    return
                }
                let recipeImage = loadImageFromLocal(filename: recipeImageFileName)
                
                guard let recipeId = selectedRecipe.id else {
                    print("")
                    return
                }
                guard let recipeName = selectedRecipe.name else {
                    print("unwrap error for name")
                    return
                }
                guard let recipeDescription = selectedRecipe.desc else {
                    return
                }
                guard let recipePrepTime = selectedRecipe.prepTime else {
                    return
                }
                guard let recipeCookTime = selectedRecipe.cookTime else {
                    return
                }
                guard let recipeDifficulty = selectedRecipe.difficulty else {
                    print("unwrap error for difficulty")
                    return
                }
                guard let recipeIngredients = selectedRecipe.ingredients else {
                    return
                }
                guard let recipeDirections = selectedRecipe.directions else {
                    return
                }
                guard let recipeProtein = selectedRecipe.protein, let recipeCarbohydrate = selectedRecipe.carbohydrate, let recipeFats = selectedRecipe.fats, let recipeCalories = selectedRecipe.calories else {
                    return
                }
                destination.recipeId = recipeId
                destination.recipe = selectedRecipe
                
                destination.name = recipeName
                destination.desc = recipeDescription
                destination.prepTime = recipePrepTime
                destination.cookTime = recipeCookTime
                destination.difficulty = recipeDifficulty
                destination.imageToLoad = recipeImage
                
                destination.ingredients = recipeIngredients
                destination.directions = recipeDirections
                
                destination.protein = recipeProtein
                destination.carbohydrates = recipeCarbohydrate
                destination.fats = recipeFats
                destination.calories = recipeCalories
            }
        }
    }
}

//override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IMAGE, for: indexPath) as! MyRecipeCollectionViewCell
//    let currentRecipe = listOfRecipe[indexPath.row]
//    
//    // Set the cell Name //
//    cell.recipeName.text = currentRecipe.name
//    
//    // Set the cell Image //
////        let storage = Storage.storage()
//    guard let url = currentRecipe.url else{
//        print("cannot unwrwap url")
//        return cell
//    }
//    
//    
//    let storageReference = storage.reference(forURL: url)
//    storageReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
//        guard let imageData = data, error == nil else {
//            print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
//            return
//        }
//        
//        if let image = UIImage(data: imageData) {
//            print("updating image view")
//            cell.imageView.image = image
//        } else {
//            print("cammot get the image")
//        }
//    }
//    
//    cell.backgroundColor = .secondarySystemFill
//    
//    
//    return cell
//}

//// Uses Caching
//override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IMAGE, for: indexPath) as! MyRecipeCollectionViewCell
//    let currentRecipe = listOfRecipe[indexPath.row]
//    
//    // Set the cell Name //
//    cell.recipeName.text = currentRecipe.name
//    
//    // Set the cell Image //
//    cell.imageView.image = UIImage(named: "placeholder")
//    guard let url = currentRecipe.url else{
//        print("cannot unwrwap url")
//        return cell
//    }
//    
//    if let cachedImage = cache.object(forKey: url as NSString) {
//        cell.imageView.image = cachedImage
//        print("found in cache")
//        return cell
//    }
//    
//    let storageReference = storage.reference(forURL: url)
//    let cellIndex = indexPath.row // Capture the current index path
//        
//    let downloadTask = storageReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
//        guard let imageData = data, error == nil else {
//            print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
//            return
//        }
//        
//        // Make sure that reused cells do not show images that are still previously being loaded in
//        if let image = UIImage(data: imageData), indexPath.row == cellIndex {
//            
//            self.cache.setObject(image, forKey: url as NSString)
//            
//            DispatchQueue.main.async {
//                print("updating image view")
//                cell.imageView.image = image
//            }
//        } else {
//            print("Cell has been reused, skipping image update")
//        }
//    }
//    
//    cell.onReuse = {
//        downloadTask.cancel()
//    }
//    
//    cell.backgroundColor = .secondarySystemFill
//    
//    return cell
//}
