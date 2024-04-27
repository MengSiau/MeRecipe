//
//  CreateRecipeV2ViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 27/4/2024.
//

import UIKit

class CreateRecipeV2ViewController: UIViewController {
    
    weak var recipeDelegate: AddRecipeDelegate?
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var recipeNameField: UITextField!
    @IBOutlet weak var recipeDescriptionField: UITextField!
    @IBOutlet weak var recipePrepTimeField: UITextField!
    @IBOutlet weak var recipeCookingTimeField: UITextField!
    @IBOutlet weak var recipeDifficultyField: UITextField!
    
    
    @IBOutlet weak var ingredientsView: UIView!
    @IBOutlet weak var ingredientTextField: UITextView!
    


    // Save button
    @IBAction func saveBtn(_ sender: Any) {
        guard let name = recipeNameField.text, let difficulty = recipeDifficultyField.text, let ingredients = ingredientTextField.text else {
            print("Issues in unwraping fields")
            return
        }
        
        // Field checking
        if name.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
        }
        
        // Add
        let newRecipe = Recipe(name: name, difficulty: difficulty, ingredients: ingredients )
        let _ = recipeDelegate?.addRecipe(newRecipe)
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            overviewView.isHidden = false
            ingredientsView.isHidden = true
        } else if segmentController.selectedSegmentIndex == 1 {
            overviewView.isHidden = true
            ingredientsView.isHidden = false
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
