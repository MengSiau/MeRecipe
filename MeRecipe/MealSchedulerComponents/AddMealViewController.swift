//
//  AddMealViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 19/5/2024.
//

import UIKit

class AddMealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var listOfRecipe: [Recipe] = []
    var categoryType: String = "breakfast"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentController()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "recipeCell")
    }
    
    // MARK: - TableView methods //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
        
        let selectedRecipe = listOfRecipe[indexPath.row]
        
        // Configure the cell
        cell.textLabel?.text = selectedRecipe.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRecipe = listOfRecipe[indexPath.row]
        databaseController?.editRecipeCategory(recipeToEdit: selectedRecipe, category: categoryType)
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: false)
        print("ADDING RECIPE")
        
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        
        for recipe in recipes {
            if recipe.category == "" {
                listOfRecipe.append(recipe)
            }
        }
        print(listOfRecipe)
    }
    
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    

    func setupSegmentController() {
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    // SegmentedView controls the 4 Views //
    @objc func segmentedControlValueChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            categoryType = "breakfast"
        } else if segmentController.selectedSegmentIndex == 1 {
            categoryType = "lunch"
        } else if segmentController.selectedSegmentIndex == 2 {
            categoryType = "dinner"
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
