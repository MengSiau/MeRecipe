//
//  ViewRecipeDetailViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/4/2024.
//

import UIKit

class ViewRecipeDetailViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeNameField: UILabel!
    @IBOutlet weak var recipeDescriptionFIeld: UILabel!
    @IBOutlet weak var recipeDifficultyAndTime: UILabel!
    
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
        
        // Load the Image
        recipeImage.image = imageToLoad

        // Processing Values
        guard let prepTime = Int(prepTime), let cookTime = Int(cookTime) else {
            print("issue unwrapping time")
            return
        }
        let totalTime = prepTime + cookTime
        let difficultyAndTime = "Difficulty: [" + difficulty + "/5] Time: " + String(totalTime) + " minutes"
        
        // Setting Texts values //
        recipeNameField.text = name
        recipeDescriptionFIeld.text = desc
        recipeDifficultyAndTime.text = difficultyAndTime
        
        
        
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
