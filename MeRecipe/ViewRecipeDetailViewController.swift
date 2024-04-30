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
    
    var recipeName: String = ""
    var recipeDescription: String = ""
    var recipePrepTime: String = ""
    var recipeCookTime: String = ""
    var recipeDifficulty: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Processing Values
        guard let prepTime = Int(recipePrepTime), let cookTime = Int(recipeCookTime) else {
            print("issue unwrapping time")
            return
        }
        let totalTime = prepTime + cookTime
        let difficultyAndTime = "Difficulty: [" + recipeDifficulty + "/5] Time: " + String(totalTime) + " minutes"
        
        // Setting Texts values
        recipeNameField.text = recipeName
        recipeDescriptionFIeld.text = recipeDescription
        recipeDifficultyAndTime.text = difficultyAndTime
        
        recipeImage.backgroundColor = UIColor.red
        
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
