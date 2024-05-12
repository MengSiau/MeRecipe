//
//  ViewRecipeDetailViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/4/2024.
//

import UIKit
import SwiftUI

class ViewRecipeDetailViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeNameField: UILabel!
    @IBOutlet weak var recipeDescriptionFIeld: UILabel!
    @IBOutlet weak var recipeDifficultyAndTime: UILabel!
    
    @IBOutlet weak var recipeIngredientStackView: UIStackView!
    @IBOutlet weak var recipeDirectionStackView: UIStackView!
    @IBOutlet weak var recipeNutritionStack: UIStackView!
    
    @IBOutlet weak var viewForChart: UIView!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(protein, carbohydrates, fats)
        if let nigga = Float(protein) {
            print(Int(round(nigga)))
        }
        
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
        
        
        print(ingredients)
        print(listIngredients)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
