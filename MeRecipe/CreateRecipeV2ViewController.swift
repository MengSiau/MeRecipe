//
//  CreateRecipeV2ViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 27/4/2024.
//

import UIKit

class CreateRecipeV2ViewController: UIViewController, UITextFieldDelegate {
    
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
    
    @IBOutlet weak var directionView: UIView!
    @IBOutlet weak var directionTextField: UITextView!
    
    @IBOutlet weak var nutrientView: UIView!
    @IBOutlet weak var recipeNameAPI: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var carbohydrateTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    
    
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
        
        recipeDifficultyField.keyboardType = .numberPad
        recipeDifficultyField.delegate = self
    }
    
    // Conform to protocol. Called for the textfield's delegate when user tap return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupUI() {
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            overviewView.isHidden = false
            ingredientsView.isHidden = true
            directionView.isHidden = true
            nutrientView.isHidden = true
        } else if segmentController.selectedSegmentIndex == 1 {
            overviewView.isHidden = true
            ingredientsView.isHidden = false
            directionView.isHidden = true
            nutrientView.isHidden = true
        } else if segmentController.selectedSegmentIndex == 2 {
            overviewView.isHidden = true
            ingredientsView.isHidden = true
            directionView.isHidden = false
            nutrientView.isHidden = true
        } else if segmentController.selectedSegmentIndex == 3 {
            overviewView.isHidden = true
            ingredientsView.isHidden = true
            directionView.isHidden = true
            nutrientView.isHidden = false
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
