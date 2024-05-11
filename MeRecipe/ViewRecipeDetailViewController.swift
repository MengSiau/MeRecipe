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
        
        // Processing ingredients stackview //
        let listIngredients = ingredients.components(separatedBy: "\n")
        recipeIngredientStackView.spacing = 8
        for ingredient in listIngredients {
            let label = UILabel()
            label.text = ingredient
            recipeIngredientStackView.addArrangedSubview(label)
        }
        
        // Processing direction stackview //
        let listDirections = directions.components(separatedBy: "\n")
        recipeDirectionStackView.spacing = 8
        for direction in listDirections {
            let label = UILabel()
            label.text = direction
            recipeDirectionStackView.addArrangedSubview(label)
        }
        
        // Setting Texts values //
        recipeNameField.text = name
        recipeDescriptionFIeld.text = desc
        recipeDifficultyAndTime.text = difficultyAndTime
        
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
        
        // Assign UIView the PieChartUIView
        viewForChart.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.centerXAnchor.constraint(equalTo: viewForChart.centerXAnchor),
            chartView.centerYAnchor.constraint(equalTo: viewForChart.centerYAnchor),
            chartView.widthAnchor.constraint(equalTo: viewForChart.widthAnchor),
            chartView.heightAnchor.constraint(equalTo: viewForChart.heightAnchor)
        ])
        
//        NSLayoutConstraint.activate([
//            chartView.leadingAnchor.constraint(equalTo: viewForChart.leadingAnchor),
//            chartView.trailingAnchor.constraint(equalTo: viewForChart.trailingAnchor),
//            chartView.topAnchor.constraint(equalTo: viewForChart.topAnchor),
//            chartView.bottomAnchor.constraint(equalTo: viewForChart.bottomAnchor)
//        ])
//        
//        view.addSubview(chartView)
//        addChild(controller)
//        
//        chartView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
//            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0),
//            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12.0),
//            chartView.widthAnchor.constraint(equalTo: chartView.heightAnchor)
//        ])
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
