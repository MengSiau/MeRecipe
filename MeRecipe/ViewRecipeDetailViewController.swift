//
//  ViewRecipeDetailViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/4/2024.
//

import UIKit
import SwiftUI

class ViewRecipeDetailViewController: UIViewController, DatabaseListener {
    
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        
    }
    
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
    
    @IBAction func addIngredientToShopplingListBtn(_ sender: Any) {
        for ingredient in listOfIngredients {
            databaseController?.addIngredient(name: ingredient)
        }
        print("add ingre btn pressed")
        let alert = UIAlertController(title: "Ingredients added", message: "Incredients have been successfully added to the shopping list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteRecipeBtn(_ sender: Any) {
        guard let recipeToDelete = recipe else {
            print("Unable to delete recipe")
            return
        }
        
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
    

    // Handled below in ... IDK
    @IBAction func editRecipeBtn(_ sender: Any) {}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
//        // Test //
//        if let selectedRecipe = selectedRecipe?.name {
//            print(selectedRecipe)
//        } else {
//            print("cannot unwrap selected recipe name")
//        }
        
        
        // Load the Image //
        recipeImage.image = imageToLoad

        // Processing Values for time and difficulty //
        guard let prepTime = Int(prepTime), let cookTime = Int(cookTime) else {
            print("issue unwrapping time")
            return
        }
        let totalTime = prepTime + cookTime
        let difficultyAndTime = "⭐️ Difficulty: [" + difficulty + "/5] | ⏰ Time: " + String(totalTime) + " minutes"
        
        // Setting Texts values //
        recipeNameField.text = name
        recipeDescriptionFIeld.text = desc
        recipeDifficultyAndTime.text = difficultyAndTime
        
        // Processing ingredients for stackview //
        let listIngredients = ingredients.components(separatedBy: "\n")
        recipeIngredientStackView.spacing = 8
        for ingredient in listIngredients {
            let label = UILabel()
            label.text = ingredient
            recipeIngredientStackView.addArrangedSubview(label)
        }
        listOfIngredients = listIngredients
        
        // Processing direction for stackview //
        let listDirections = directions.components(separatedBy: "\n")
        recipeDirectionStackView.spacing = 8
        for direction in listDirections {
            let label = UILabel()
            label.text = direction
            recipeDirectionStackView.addArrangedSubview(label)
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
//            magic(selectedRecipe: targetRecipe)
        } else {
            print("Cannot find recipe with that id")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // TODO: This loads via firebase. But popping back means vertical stack duplicates. ViewWillAppear -> Call a self made function that resets the viewstacks
    // This uses the recipe grabbed from firebase via id. This unwraps + sets local vars for recipe attributes.
    
//    func magic(selectedRecipe: Recipe) {
//        
//        guard let recipeImageFileName = selectedRecipe.imageFileName else {
//            return
//        }
//        let retrievedImage = loadImageFromLocal(filename: recipeImageFileName)
//        
//        guard let recipeId = selectedRecipe.id else {
//            print("")
//            return
//        }
//        guard let recipeName = selectedRecipe.name else {
//            print("unwrap error for name")
//            return
//        }
//        guard let recipeDescription = selectedRecipe.desc else {
//            return
//        }
//        guard let recipePrepTime = selectedRecipe.prepTime else {
//            return
//        }
//        guard let recipeCookTime = selectedRecipe.cookTime else {
//            return
//        }
//        guard let recipeDifficulty = selectedRecipe.difficulty else {
//            print("unwrap error for difficulty")
//            return
//        }
//        guard let recipeIngredients = selectedRecipe.ingredients else {
//            return
//        }
//        guard let recipeDirections = selectedRecipe.directions else {
//            return
//        }
//        guard let recipeProtein = selectedRecipe.protein, let recipeCarbohydrate = selectedRecipe.carbohydrate, let recipeFats = selectedRecipe.fats, let recipeCalories = selectedRecipe.calories else {
//            return
//        }
//        
//        // Setting
//        name = recipeName
//        desc = recipeDescription
//        prepTime = recipePrepTime
//        cookTime = recipeCookTime
//        difficulty = recipeDifficulty
//        imageToLoad = retrievedImage
//        
//        ingredients = recipeIngredients
//        directions = recipeDirections
//        
//        protein = recipeProtein
//        carbohydrates = recipeCarbohydrate
//        fats = recipeFats
//        calories = recipeCalories
//        
//        
//        // Settings Image //
//        recipeImage.image = retrievedImage
//
//        // Processing Values for time and difficulty //
//        guard let prepTime = Int(recipePrepTime), let cookTime = Int(recipeCookTime) else {
//            print("issue unwrapping time")
//            return
//        }
//        let totalTime = prepTime + cookTime
//        let difficultyAndTime = "⭐️ Difficulty: [" + recipeDifficulty + "/5] | ⏰ Time: " + String(totalTime) + " minutes"
//        
//        // Setting Texts values //
//        recipeNameField.text = recipeName
//        recipeDescriptionFIeld.text = recipeDescription
//        recipeDifficultyAndTime.text = difficultyAndTime
//        
//        // Processing ingredients for stackview //
//        let listIngredients = recipeIngredients.components(separatedBy: "\n")
//        recipeIngredientStackView.spacing = 8
//        for ingredient in listIngredients {
//            let label = UILabel()
//            label.text = ingredient
//            recipeIngredientStackView.addArrangedSubview(label)
//        }
//        
//        // Processing direction for stackview //
//        let listDirections = recipeDirections.components(separatedBy: "\n")
//        recipeDirectionStackView.spacing = 8
//        for direction in listDirections {
//            let label = UILabel()
//            label.text = direction
//            recipeDirectionStackView.addArrangedSubview(label)
//        }
//        
//        // Processing nutrition for stackview //
//        let proteinLabel = UILabel()
//        var proteinText = "Protein: \(recipeProtein) g"
//        if protein == "" {
//            proteinText = String(proteinText.dropLast(1))
//        }
//        let attributedString1 = NSMutableAttributedString(string: proteinText)
//        attributedString1.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 8))
//        proteinLabel.attributedText = attributedString1
//        
//        let carbohydrateLabel = UILabel()
//        var carbohydrateText = "Carbohydrate: \(recipeCarbohydrate) g"
//        if carbohydrates == "" {
//            carbohydrateText = String(carbohydrateText.dropLast(1))
//        }
//        let attributedString2 = NSMutableAttributedString(string: carbohydrateText)
//        attributedString2.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 13))
//        carbohydrateLabel.attributedText = attributedString2
//        
//        let fatsLabel = UILabel()
//        var fatsText = "Fats: \(recipeFats) g"
//        if fats == "" {
//            fatsText = String(fatsText.dropLast(1))
//        }
//        let attributedString3 = NSMutableAttributedString(string: fatsText)
//        attributedString3.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 5))
//        fatsLabel.attributedText = attributedString3
//        
//        let caloriesLabel = UILabel()
//        let caloriesText = "Calories: \(recipeCalories)"
//        let attributedString4 = NSMutableAttributedString(string: caloriesText)
//        attributedString4.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: 9))
//        caloriesLabel.attributedText = attributedString4
//        
//        recipeNutritionStack.spacing = 8
//        recipeNutritionStack.addArrangedSubview(proteinLabel)
//        recipeNutritionStack.addArrangedSubview(carbohydrateLabel)
//        recipeNutritionStack.addArrangedSubview(fatsLabel)
//        recipeNutritionStack.addArrangedSubview(caloriesLabel)
//        
//        
//        // Cast string that are floats to int //
//        guard let proteinFloat = Float(recipeProtein), let carbohydrateFloat = Float(recipeCarbohydrate), let fatsFloat = Float(recipeFats) else {
//            print("Cannot unwrap nutrition values")
//            return
//        }
//        let proteinInt = Int(round(proteinFloat))
//        let carbohydrateInt = Int(round(carbohydrateFloat))
//        let fatsInt = Int(round(fatsFloat))
//        
//        let controller = UIHostingController(rootView: PieChartUIView())
//        guard let chartView = controller.view else {
//            print("blah")
//            return
//        }
//        
//        // Add values to the PieChartUIView //
//        controller.rootView.chartData.append(NutritionDataStructure(name: "Protein", value: proteinInt))
//        controller.rootView.chartData.append(NutritionDataStructure(name: "Carbo", value: carbohydrateInt))
//        controller.rootView.chartData.append(NutritionDataStructure(name: "Fats", value: fatsInt))
//        
//        // Assign UIView the PieChartUIView //
//        viewForChart.addSubview(chartView)
//        chartView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            chartView.centerXAnchor.constraint(equalTo: viewForChart.centerXAnchor),
//            chartView.centerYAnchor.constraint(equalTo: viewForChart.centerYAnchor),
//            chartView.widthAnchor.constraint(equalTo: viewForChart.widthAnchor),
//            chartView.heightAnchor.constraint(equalTo: viewForChart.heightAnchor)
//        ])
//    }
    
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

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editRecipeSegue" {
            let destination = segue.destination as! CreateRecipeV2ViewController
            
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
