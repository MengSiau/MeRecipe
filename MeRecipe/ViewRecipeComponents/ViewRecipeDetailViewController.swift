//
//  ViewRecipeDetailViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/4/2024.
//

import UIKit
import SwiftUI

class ViewRecipeDetailViewController: UIViewController, DatabaseListener {
    
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
    var listOfRecipe: [Recipe] = []
    var selectedRecipe: Recipe?
    var listOfIngredients: [String] = []

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeNameField: UILabel!
    @IBOutlet weak var recipeDescriptionFIeld: UILabel!
    @IBOutlet weak var recipeDifficultyAndTime: UILabel!
    
    @IBOutlet weak var recipeIngredientStackView: UIStackView!
    @IBOutlet weak var recipeDirectionStackView: UIStackView!
    @IBOutlet weak var recipeNutritionStack: UIStackView!
    
    @IBOutlet weak var viewForChart: UIView!
    
    var recipeId: String = ""
    var recipe: Recipe?
    
    var name: String = ""
    var desc: String = ""
    var prepTime: String = ""
    var cookTime: String = ""
    var difficulty: String = ""
    var imageToLoad: UIImage?
    
    var ingredients: String = ""
    var directions: String = ""
    
    var protein: String = ""
    var carbohydrates: String = ""
    var fats: String = ""
    var calories: String = ""
    
    // Btn that adds ingredients to the shopping list//
    @IBAction func addIngredientToShopplingListBtn(_ sender: Any) {
        
        // If ingredient list empty, do not add anything
        if ingredients == "" {
            let alert = UIAlertController(title: "Error", message: "Unable to add an empty ingredient list to the shopping list. Please fill in ingredient list and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // If ingredient list not empty, proceed to add to shopping cart
        for ingredient in listOfIngredients {
            databaseController?.addIngredient(name: ingredient)
        }
        print("add ingre btn pressed")
        let alert = UIAlertController(title: "Ingredients added", message: "Incredients have been successfully added to the shopping list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Btn that deletes the recipe being viewed right now. Popup warning presented onclick //
    @IBAction func deleteRecipeBtn(_ sender: Any) {
        guard let recipeToDelete = recipe else {
            print("Unable to delete recipe")
            return
        }
        
        // Popup warning: confirm to delete, cancel to dismiss //
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete recipe?", preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.databaseController?.deleteRecipe(recipe: recipeToDelete)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            return
        }
        
        alertController.addAction(leaveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    

    @IBAction func editRecipeBtn(_ sender: Any) {}

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Load the Image + Name//
        recipeImage.image = imageToLoad
        recipeNameField.text = name
        
        // Initialize totalTime and difficultyAndTime with default values
        var totalTime: Int = 0
        var difficultyAndTime: String = "⭐️ Difficulty: [0/9] | ⏰ Time: 0 minutes"

        if let prepTimeInt = Int(prepTime), let cookTimeInt = Int(cookTime) {
            totalTime = prepTimeInt + cookTimeInt
            difficultyAndTime = "⭐️ Difficulty: [\(difficulty)/9] | ⏰ Time: \(totalTime) minutes"
        } else {
            // If unwrapping fails, use default values
            totalTime = 0
            difficultyAndTime = "⭐️ Difficulty: [0/9] | ⏰ Time: 0 minutes"
        }

        // Setting Texts values //
        if desc == "" {
            recipeDescriptionFIeld.text = "# No description given"
            recipeDescriptionFIeld.font = UIFont.boldSystemFont(ofSize: recipeDescriptionFIeld.font.pointSize) // bold
        } else {
            recipeDescriptionFIeld.text = desc
        }
        recipeDifficultyAndTime.text = difficultyAndTime
        
        // Processing ingredients for stackview //
        if ingredients == "" { // If ingredient is empty, return the following ...
            recipeIngredientStackView.spacing = 8
            let label = UILabel()
            label.text = "# No ingredients have been given"
            label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
            recipeIngredientStackView.addArrangedSubview(label)
        } else { // Else, populate the stackview
            let listIngredients = ingredients.components(separatedBy: "\n")
            recipeIngredientStackView.spacing = 8
            for ingredient in listIngredients {
                let label = UILabel()
                label.text = ingredient
                recipeIngredientStackView.addArrangedSubview(label)
            }
            listOfIngredients = listIngredients // Used for add to shopping cart btn
        }

        // Processing direction for stackview //
        if directions == "" { // If directions is empty, return the following ...
            recipeDirectionStackView.spacing = 8
            let label = UILabel()
            label.text = "# No directions have been given"
            label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
            recipeDirectionStackView.addArrangedSubview(label)
        } else { // else, populate the stack view
            let listDirections = directions.components(separatedBy: "\n")
            recipeDirectionStackView.spacing = 8
            for direction in listDirections {
                let label = UILabel()
                label.text = direction
                recipeDirectionStackView.addArrangedSubview(label)
            }
        }
        
        // Processing nutrition for stackview //
        let proteinLabel = UILabel()
        var proteinText = "Protein: \(protein) g"
        if protein == "" {
            proteinText = String(proteinText.dropLast(1))
        }
        let attributedString1 = NSMutableAttributedString(string: proteinText)
        attributedString1.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 8))
        proteinLabel.attributedText = attributedString1
        
        let carbohydrateLabel = UILabel()
        var carbohydrateText = "Carbohydrate: \(carbohydrates) g"
        if carbohydrates == "" {
            carbohydrateText = String(carbohydrateText.dropLast(1))
        }
        let attributedString2 = NSMutableAttributedString(string: carbohydrateText)
        attributedString2.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 13))
        carbohydrateLabel.attributedText = attributedString2
        
        let fatsLabel = UILabel()
        var fatsText = "Fats: \(fats) g"
        if fats == "" {
            fatsText = String(fatsText.dropLast(1))
        }
        let attributedString3 = NSMutableAttributedString(string: fatsText)
        attributedString3.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 5))
        fatsLabel.attributedText = attributedString3
        
        let caloriesLabel = UILabel()
        let caloriesText = "Calories: \(calories)"
        let attributedString4 = NSMutableAttributedString(string: caloriesText)
        attributedString4.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 9))
        caloriesLabel.attributedText = attributedString4
        
        recipeNutritionStack.spacing = 8
        recipeNutritionStack.addArrangedSubview(proteinLabel)
        recipeNutritionStack.addArrangedSubview(carbohydrateLabel)
        recipeNutritionStack.addArrangedSubview(fatsLabel)
        recipeNutritionStack.addArrangedSubview(caloriesLabel)
        
        // Check if any nutrition value is missing (print message saying we cannot create pie chart)
        if protein.isEmpty || carbohydrates.isEmpty || fats.isEmpty {
            let warningLabel = UILabel()
            warningLabel.text = "# Unable to create pie chart due to missing nutrition values"
            warningLabel.font = UIFont.boldSystemFont(ofSize: warningLabel.font.pointSize) // Bold
            warningLabel.textColor = .red
            warningLabel.numberOfLines = 0 // Enable sentence wrapping
            warningLabel.lineBreakMode = .byWordWrapping
            recipeNutritionStack.addArrangedSubview(warningLabel)
        }
        
        // Cast string that are floats to int //
        guard let proteinFloat = Float(protein), let carbohydrateFloat = Float(carbohydrates), let fatsFloat = Float(fats) else {
            print("Cannot unwrap nutrition values")
            return
        }
        let proteinInt = Int(round(proteinFloat))
        let carbohydrateInt = Int(round(carbohydrateFloat))
        let fatsInt = Int(round(fatsFloat))
        
        let controller = UIHostingController(rootView: PieChartUIView())
        guard let chartView = controller.view else {
            print("blah")
            return
        }
        
        // Add values to the PieChartUIView //
        controller.rootView.chartData.append(NutritionDataStructure(name: "Protein", value: proteinInt))
        controller.rootView.chartData.append(NutritionDataStructure(name: "Carbo", value: carbohydrateInt))
        controller.rootView.chartData.append(NutritionDataStructure(name: "Fats", value: fatsInt))
        
        // Assign UIView the PieChartUIView //
        viewForChart.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.centerXAnchor.constraint(equalTo: viewForChart.centerXAnchor),
            chartView.centerYAnchor.constraint(equalTo: viewForChart.centerYAnchor),
            chartView.widthAnchor.constraint(equalTo: viewForChart.widthAnchor),
            chartView.heightAnchor.constraint(equalTo: viewForChart.heightAnchor)
        ])

    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
        if let targetRecipe = listOfRecipe.first(where: { $0.id == recipeId }) {
            selectedRecipe = targetRecipe
            print("found recipe")
        } else {
            print("Cannot find recipe with that id")
        }
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
    
    
    // Helper function to retrieve locally stored images by filename //
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
    
    // MARK: - Navigation

   // Pre-loads the values into the createRecipeVC, with the mode set to edit (called different firebase method to edit instead to create) //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editRecipeSegue" {
            let destination = segue.destination as! CreateRecipeViewController
            
            destination.mode = "edit"
            destination.navigationItem.title = "Editing \(name)"
            
            destination.recipeToReplace = recipe
            destination.name = name
            
            destination.name = name
            destination.desc = desc
            destination.prepTime = prepTime
            destination.cookTime = cookTime
            destination.difficulty = difficulty
            destination.imageToLoad = imageToLoad // check
            
            destination.ingredients = ingredients
            destination.directions = directions
            
            destination.protein = protein
            destination.carbohydrates = carbohydrates
            destination.fats = fats
            destination.calories = calories
        }
    }
    

}
