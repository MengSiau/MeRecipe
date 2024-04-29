//
//  ViewRecipeDetailViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/4/2024.
//

import UIKit

class ViewRecipeDetailViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var recipeDifficultyField: UILabel!
    @IBOutlet weak var recipeNameField: UILabel!
    
    var recipeName: String = ""
    var recipeDifficulty: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeNameField.text = recipeName
        recipeDifficultyField.text = recipeDifficulty

        // Do any additional setup after loading the view.
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
