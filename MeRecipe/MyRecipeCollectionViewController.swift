//
//  MyRecipeCollectionViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import UIKit
import Firebase
import FirebaseStorage

class MyRecipeCollectionViewController: UICollectionViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, AddRecipeDelegate, DatabaseListener {
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
//    var storageReference = Storage.storage().reference()
    var recipeRef: CollectionReference?
    
    
    let CELL_IMAGE = "imageCell"
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var listOfRecipe: [Recipe] = []
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
        
        // SEARCH BAR //
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // TOOL BAR //
        view.addSubview(bottomToolbar)
        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        bottomToolbar.items = [addButton]
       
    }
    // name: String?, description: String?, prepTime: String?, cookTime: String?, difficulty: String?, ingredients: String?)
    func generateTestRecipe() {
//        listOfRecipe.append(Recipe(name: "Apple Pie",  description: "sweet apple pie!", prepTime: "20", cookTime: "40", difficulty: "3", ingredients: "30g Apple, 40g Sugar, 500mL milk"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
        collectionView.reloadData();
    }

    // MARK: UICollectionViewDataSource

    // Set to 20
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return listOfRecipe.count
    }

    // Responsible for the creation/customization of the CollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IMAGE, for: indexPath) as! MyRecipeCollectionViewCell
        let currentRecipe = listOfRecipe[indexPath.row]
        
        // Set the cell Name //
        cell.recipeName.text = currentRecipe.name
        
        
        // Set the cell Image //
        let storage = Storage.storage()
        guard let url = currentRecipe.url else{
            print("cannot unwrwap url")
            return cell
        }
        let storageReference = storage.reference(forURL: url)
        
        storageReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
            guard let imageData = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let image = UIImage(data: imageData) {
                cell.imageView.image = image
            } else {
                print("cammot get the image")
            }
        }
        cell.backgroundColor = .secondarySystemFill
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRecipeSegue" {
            let destination = segue.destination as! CreateRecipeV2ViewController
            destination.recipeDelegate = self
        } else if segue.identifier == "recipeDetailSegue" {
            if let selectedIndexPaths = collectionView.indexPathsForSelectedItems, let indexPath = selectedIndexPaths.first {
                let destination = segue.destination as! ViewRecipeDetailViewController
                let selectedRecipe = listOfRecipe[indexPath.row]
                print(indexPath.row)
                
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
                
                destination.recipeName = recipeName
                destination.recipeDescription = recipeDescription
                destination.recipePrepTime = recipePrepTime
                destination.recipeCookTime = recipeCookTime
                destination.recipeDifficulty = recipeDifficulty
            }
        }
    }
}
