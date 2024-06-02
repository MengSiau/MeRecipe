//
//  MyRecipeCollectionViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import UIKit
import Firebase
import FirebaseStorage

class MyRecipeCollectionViewController: UICollectionViewController, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout, DatabaseListener {

    
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
    var recipeRef: CollectionReference?
    let storage = Storage.storage()

    
    let CELL_IMAGE = "imageCell"
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var listOfRecipe: [Recipe] = []
    var filteredListOfRecipe: [Recipe] = []
    
    let bottomToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Determines the layout of collectionViewCells
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
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
        let shoppingListBtn = UIBarButtonItem(image: UIImage(systemName: "cart"), style: .plain, target: self, action: #selector(shoppingListBtnTapped))
        let mealScheduleBtn = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(mealScheduleBtnTapped))
        let settingsBtn = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Set the toolbar items
        self.toolbarItems = [shoppingListBtn, flexibleSpace, mealScheduleBtn, flexibleSpace, settingsBtn]
    }
    
    // Action functions for bot nav bar //
    @objc func homeButtonTapped() {}
    @objc func shoppingListBtnTapped() {performSegue(withIdentifier: "shoppingListSegue", sender: self)}
    @objc func mealScheduleBtnTapped() {performSegue(withIdentifier: "mealSchedulerSegue", sender: self)}
    @objc func settingsButtonTapped() {performSegue(withIdentifier: "settingsSegue", sender: self)}
    
    // Helper function to set screen to darkmode //
    private func setDarkMode(_ isDarkMode: Bool) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.toggleDarkMode(isDarkMode)
        }
    }
    
    // Allows CollectionView to refelct the search bar input //
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
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        
        // Enable bot nav bar //
        self.navigationController?.isToolbarHidden = true
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
        updateSearchResults(for: navigationItem.searchController!)
    }

    // MARK: UICollectionViewDataSource

    // Only need one section as its just Recipes //
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Number of cells depend on stored recipes and the filtered ones //
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredListOfRecipe.count
    }

    // Function for getting Recipe Image that may have been stored locally //
    private func loadImageFromLocal(filename: String) -> UIImage? {
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
    private func checkInternetConnection() {
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
    
    // Responsible for the creation/customization of the CollectionViewCell //
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
        
        // If image not locally stored, attempt to retrieve image from cloud by getting ImageData via URL nested in Recipe //
        let storageReference = storage.reference(forURL: url)
        let cellIndex = indexPath.row // Capture the current index path
            
        // Attempt to retrieve the image data stored on firebase by storage reference //
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
    
    // Defines the layout of the CollectionViewCells //
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
    
    
    // Prepares the Recipe values for the ViewReciipeDetail page + Segues to createRecipeVC with the intention to create recipes //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRecipeSegue" {
            let destination = segue.destination as! CreateRecipeViewController
            destination.mode = "create"
            
        } else if segue.identifier == "recipeDetailSegue" {
            if let selectedIndexPaths = collectionView.indexPathsForSelectedItems, let indexPath = selectedIndexPaths.first {
                let destination = segue.destination as! ViewRecipeDetailViewController
                let selectedRecipe = listOfRecipe[indexPath.row]
                
                // Perform error checking. Unlikely to catch error due to error checking done in recipe creation. //
                
                guard let recipeImageFileName = selectedRecipe.imageFileName else {
                    return
                }
                let recipeImage = loadImageFromLocal(filename: recipeImageFileName)
                
                guard let recipeId = selectedRecipe.id,
                      let recipeName = selectedRecipe.name,
                      let recipeDescription = selectedRecipe.desc,
                      let recipePrepTime = selectedRecipe.prepTime,
                      let recipeCookTime = selectedRecipe.cookTime,
                      let recipeDifficulty = selectedRecipe.difficulty,
                      let recipeIngredients = selectedRecipe.ingredients,
                      let recipeDirections = selectedRecipe.directions else {
                    print("Error unwrapping one or more basic recipe fields")
                    return
                }
    
                guard let recipeProtein = selectedRecipe.protein, let recipeCarbohydrate = selectedRecipe.carbohydrate, let recipeFats = selectedRecipe.fats, let recipeCalories = selectedRecipe.calories else {
                    return
                }
                
                // Load the details into destination //
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

