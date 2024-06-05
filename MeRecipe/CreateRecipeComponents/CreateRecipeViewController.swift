//
//  CreateRecipeV2ViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 27/4/2024.
//

import UIKit

class CreateRecipeViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    weak var databaseController: DatabaseProtocol?
    var mode: String?
    var recipeToReplace: Recipe?
    
    let screenIndexOverview = 0
    let screenIndexIngredeints = 1
    let screenIndexDirections = 2
    let screenIndexNutrients = 3
    
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
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var recipeNameField: UITextField!
    @IBOutlet weak var recipeDescriptionField: UITextField!
    @IBOutlet weak var recipePrepTimeField: UITextField!
    @IBOutlet weak var recipeCookingTimeField: UITextField!
    @IBOutlet weak var recipeDifficultyField: UITextField!
    @IBOutlet weak var recipePreviewImage: UIImageView!
    
    @IBOutlet weak var ingredientsView: UIView!
    @IBOutlet weak var ingredientTextField: UITextView!
    
    @IBOutlet weak var directionView: UIView!
    @IBOutlet weak var directionTextField: UITextView!
    
    let REQUEST_STRING = "https://api.api-ninjas.com/v1/nutrition?query="
    let API_KEY = "gXhfhW09+sIxVJ9P7D6LqQ==jDg5rHdQVtq3F3Dj"
    @IBOutlet weak var nutrientView: UIView!
    @IBOutlet weak var recipeNameAPI: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var carbohydrateTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    
    // Allows users to choose different methods for uploading images //
    @IBAction func selectPreviewImageBtn(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: "Select Option:", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            controller.sourceType = .camera
            self.present(controller, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
        
        let albumAction = UIAlertAction(title: "Photo Album", style: .default) { action in
            controller.sourceType = .savedPhotosAlbum
            self.present(controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                actionSheet.addAction(cameraAction)
        }
        
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet , animated: true, completion: nil)
    }
    
    // Btn for auto-generating nutrients via API + Called the API request func //
    @IBAction func generateNutrientsAPI(_ sender: Any) {
        guard let query = recipeNameAPI.text else {
            print("No recipe name specified")
            displayMessage(title: "Input Error", message: "No recipe name specified")
            return
        }
        
        Task {
            print("requestFunc called")
            await requestNutrients(query)
        }

    }
    
    // Creates a API Request + Assigns TextFields with the retrieved values //
    func requestNutrients(_ recipeName: String) async {
        guard let url = URL(string: REQUEST_STRING+recipeName) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(API_KEY, forHTTPHeaderField: "X-Api-Key") // Snippet from api-ninja
        
        // Responsible for showing the loading animatopm
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        // Request the data
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            // Stop the loading sign
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            // This will run when we fail to fetch the data from api
            if let error = error {
                DispatchQueue.main.async {
                    self.displayMessage(title: "Error", message: "No internet connection or request failed. Please try again.")
                }
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                if let firstItem = jsonArray.first {
                    
                    // Selecting the key information only from the jsonArray
                    if let protein = firstItem["protein_g"] as? Double, let carbs = firstItem["carbohydrates_total_g"] as? Double, let fats = firstItem["fat_total_g"] as? Double, let calories = firstItem["calories"] as? Double {
                        
                        DispatchQueue.main.async {
                            self.proteinTextField.text = "\(protein)"
                            self.carbohydrateTextField.text = "\(carbs)"
                            self.fatTextField.text = "\(fats)"
                            self.caloriesTextField.text = "\(calories)"
                        }
                        
                    } else {
                        print("Error: Cannot unwrap values")
                        DispatchQueue.main.async {
                            self.displayMessage(title: "Error", message: "There was an issue getting the values from webserver")
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async { // When we dont get an array, it means no recipe for that exists
                        self.displayMessage(title: "Recipe not found", message: "Please try use another keyword for your recipe")
                        print("Cannot get JSON: Likely due to unknown recipe name.")
                    }
                }
            }
        }
        task.resume()
    }

    // Save button (ADDS/EDITS THE RECIPE) //
    @IBAction func saveBtn(_ sender: Any) {
        guard let name = recipeNameField.text, let description = recipeDescriptionField.text, let prepTime = recipePrepTimeField.text, let cookTime = recipeCookingTimeField.text, let difficulty = recipeDifficultyField.text, var ingredients = ingredientTextField.text, var directions = directionTextField.text, let protein = proteinTextField.text, let carbohydrate = carbohydrateTextField.text, let fats = fatTextField.text, let calories = caloriesTextField.text else {
            print("Issues in unwraping fields")
            return
        }
    
        // Field checking (minimum name required)
        if name.isEmpty {
            displayMessage(title: "Field Error", message: "Please ensure that a name is given at minimum")
        }
        
        // Field checking difficulty (must be int between 1-9)
        if let difficultyText = recipeDifficultyField.text, !difficultyText.isEmpty {
            if let difficulty = Int(difficultyText), (1...9).contains(difficulty) {
                let _ = difficulty
            } else {
                print("Difficulty must be a single digit between 1 and 9")
                displayMessage(title: "Field Error", message: "Difficulty must be a single digit between 1 and 9")
                return
            }
        }
        
        // Handling image //
        let image: UIImage
        if let selectedImage = recipePreviewImage.image {
            image = selectedImage
        } else {
            print("Cannot unwrap chosen image or no image selected. Assigning placeholder image")
            guard let placeholderImage = UIImage(named: "placeholderImage") else {
                displayMessage(title: "Error", message: "Placeholder image could not be loaded. Please upload an image from photo album")
                return
            }
            image = placeholderImage
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            displayMessage(title: "Error", message: "Image data could not be compressed. Try another image")
            return
        }
        
        // Turns the placeholder text into empty string //
        print(ingredients)
        if ingredients == "List ingredients here" {
            ingredients = ""
        }
        if directions == "List directions here" {
            directions = ""
        }
        
        // Calls database methods//
        if mode == "create" {
            let _ = databaseController?.addRecipe(name: name, desc: description, prepTime: prepTime, cookTime: cookTime, difficulty: difficulty, imageData: imageData, ingredients: ingredients, directions: directions, protein: protein, carbohydrate: carbohydrate, fats: fats, calories: calories)
            navigationController?.popViewController(animated: true)
        } else if mode == "edit" {
            let _ = databaseController?.editRecipe(recipeToEdit: recipeToReplace, name: name, desc: description, prepTime: prepTime, cookTime: cookTime, difficulty: difficulty, imageData: imageData, ingredients: ingredients, directions: directions, protein: protein, carbohydrate: carbohydrate, fats: fats, calories: calories)
            navigationController?.popToRootViewController(animated: true) // Pops back to home page
            print("edit mode called")
        } else {
            print("Invalid mode")
            return
        }

    }
    
    var activityIndicator = UIActivityIndicatorView(style: .large)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        self.view.backgroundColor = UIColor.systemGray6
        
        // Set up segmented controller to switch between 4 views //
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        // Set up firebase //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // UITextView delegate for placeholder text //
        ingredientTextField.text = "List ingredients here"
        ingredientTextField.textColor = UIColor.lightGray
        ingredientTextField.returnKeyType = .done
        ingredientTextField.delegate = self
        
        directionTextField.text = "List directions here"
        directionTextField.textColor = UIColor.lightGray
        directionTextField.returnKeyType = .done
        directionTextField.delegate = self
        
        // Keyboard settings for difficulty field //
        recipeDifficultyField.delegate = self
        recipeDifficultyField.keyboardType = .numberPad
        
        // Sets of the toolbar above the ingredient textView keyboard //
        ingredientToolBar()
        
        if mode == "edit" {
            recipeNameField.text = name
            recipeDescriptionField.text = desc
            recipePrepTimeField.text = prepTime
            recipeCookingTimeField.text = cookTime
            recipeDifficultyField.text = difficulty
            recipePreviewImage.image = imageToLoad
            
            ingredientTextField.text = ingredients
            directionTextField.text = directions
            
            proteinTextField.text = protein
            carbohydrateTextField.text = carbohydrates
            fatTextField.text = fats
            caloriesTextField.text = calories
        }
        
        // Top left back button will now present an alert before popping back //
        let customBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(customBackAction))
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    // Presents warning when popping back (top left back btn) //
    @objc func customBackAction() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to go back? Inputted fields or changes made will not be saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }

    // Adds bar btns above keyboard for ingredient textView //
    func ingredientToolBar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let oneQuarterButton = UIBarButtonItem(title: "1/4", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let oneThirdButton = UIBarButtonItem(title: "1/3", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let oneHalfButton = UIBarButtonItem(title: "1/2", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let twoThirdButton = UIBarButtonItem(title: "2/3", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let threeQuarterButton = UIBarButtonItem(title: "3/4", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let tspButton = UIBarButtonItem(title: "tsp", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let mlButton = UIBarButtonItem(title: "ml", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let gramsButton = UIBarButtonItem(title: "grams", style: .plain, target: self, action: #selector(measurementButtonTapped))
        
        toolbar.items = [oneQuarterButton, oneThirdButton, oneHalfButton, twoThirdButton, threeQuarterButton, tspButton, mlButton, gramsButton]
        
        ingredientTextField.inputAccessoryView = toolbar
    }
    
    
    // Adds the bar button text ontop of what the user has typed (ingredient UITextView) //
    @objc func measurementButtonTapped(sender: UIBarButtonItem) {
        if let text = ingredientTextField.text {
            ingredientTextField.text = text + sender.title!
        } else {
            ingredientTextField.text = sender.title
        }
    }
    
    // TextView Delegate: changes from placeholder text to user typed text (UITextView does not have placeholders...) //
    func textViewDidBeginEditing(_ textView: UITextView) {
        if ingredientTextField.text == "List ingredients here" {
            ingredientTextField.text = ""
            ingredientTextField.textColor = UIColor.black
        }
        
        // For this one, on click initially adds "1)" //
        if directionTextField.text == "List directions here" {
            directionTextField.text = "1) "
            directionTextField.textColor = UIColor.black
        }
    }
    
    // UITextView delegate: Called for the textfield's delegate when user tap return. //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // UITextView delegate: Ensures that when "done" is pressed, directionTextView goes to new line + calls method to add numbers //
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == directionTextField && text == "\n" {
            insertNewLineNumber(in: textView)
            return false
        }
        return true
    }
    
    // UITextView delegate helper method: Adds a new line number incrementally//
    private func insertNewLineNumber(in textView: UITextView) {
        if var currentText = textView.text {
            let currentLineNumber = currentText.components(separatedBy: "\n").count + 1 // Each line broken down to elements in array to determine number
            currentText += "\n\(currentLineNumber)) "
            textView.text = currentText // update textView
        }
    }
    
    // UITextView delegate: Dismisses the keyboard //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    // SegmentedView controls the 4 Views //
    @objc func segmentedControlValueChanged() {
        if segmentController.selectedSegmentIndex == screenIndexOverview {
            overviewView.isHidden = false
            ingredientsView.isHidden = true
            directionView.isHidden = true
            nutrientView.isHidden = true
        } else if segmentController.selectedSegmentIndex == screenIndexIngredeints {
            overviewView.isHidden = true
            ingredientsView.isHidden = false
            directionView.isHidden = true
            nutrientView.isHidden = true
        } else if segmentController.selectedSegmentIndex == screenIndexDirections {
            overviewView.isHidden = true
            ingredientsView.isHidden = true
            directionView.isHidden = false
            nutrientView.isHidden = true
        } else if segmentController.selectedSegmentIndex == screenIndexNutrients {
            overviewView.isHidden = true
            ingredientsView.isHidden = true
            directionView.isHidden = true
            nutrientView.isHidden = false
        }
    }
    
    // UIImagePickerControllerDelegate -> This func is called when user has selected a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            recipePreviewImage.image = pickedImage
        }
        // Once image selected, dismiss
        dismiss(animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate -> This func is called when the image picker has been cancelled.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
