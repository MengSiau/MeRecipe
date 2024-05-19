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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        databaseController?.editRecipeCategory(recipeToEdit: selectedRecipe, category: "breakfast")
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: false)
        print("row clicked")
        
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
