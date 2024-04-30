//
//  CreateRecipeViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/4/2024.
//

import UIKit

class CreateRecipeViewController: UIViewController {

    weak var recipeDelegate: AddRecipeDelegate?
    @IBOutlet weak var recipeNameField: UITextField!
    @IBOutlet weak var recipeDifficultyField: UITextField!
    
    @IBAction func createRecipeBtn(_ sender: Any) {
        
        guard let recipeName = recipeNameField.text, let recipeDifficulty = recipeDifficultyField.text else {
            print("enter all fields")
            return
        }
        
        // name: String?, description: String?, prepTime: String?, cookTime: String?, difficulty: String?, ingredients: String?)
//        let newRecipe = Recipe(name: recipeName, difficulty: recipeDifficulty, ingredients: "dd")
//        let _ = recipeDelegate?.addRecipe(newRecipe)
        
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
