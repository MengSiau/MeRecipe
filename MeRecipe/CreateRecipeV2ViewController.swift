//
//  CreateRecipeV2ViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 27/4/2024.
//

import UIKit

class CreateRecipeV2ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    weak var recipeDelegate: AddRecipeDelegate?
    weak var databaseController: DatabaseProtocol?
    
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
    var proteinVal: String? = ""
    
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
        print("API btn pressed")
        guard let query = recipeNameAPI.text else {
            print("No recipe name specified") // TODO: make pop up later
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
        request.setValue(API_KEY, forHTTPHeaderField: "X-Api-Key")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                if let firstItem = jsonArray.first {
                    
                    if let protein = firstItem["protein_g"] as? Double, let carbs = firstItem["carbohydrates_total_g"] as? Double, let fats = firstItem["fat_total_g"] as? Double, let calories = firstItem["calories"] as? Double {
                        
                        DispatchQueue.main.async {
                            self.proteinTextField.text = "\(protein)"
                            self.carbohydrateTextField.text = "\(carbs)"
                            self.fatTextField.text = "\(fats)"
                            self.caloriesTextField.text = "\(calories)"
                        }
                        
                    } else {
                        print("Error: Cannot unwrap values")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Recipe not found", message: "Please try use another keyword for your recipe")
                        print("Cannot get JSON: Likely due to unknown recipe name.")
                    }
                    
                }
            }
        }
        task.resume()
    }

    
    // Save button (ADDS THE RECIPE) //
    @IBAction func saveBtn(_ sender: Any) {
        guard let name = recipeNameField.text, let description = recipeDescriptionField.text, let prepTime = recipePrepTimeField.text, let cookTime = recipeCookingTimeField.text, let difficulty = recipeDifficultyField.text, let ingredients = ingredientTextField.text, let directions = directionTextField.text, let protein = proteinTextField.text, let carbohydrate = carbohydrateTextField.text, let fats = fatTextField.text, let calories = caloriesTextField.text else {
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
        
        // Handling image
        // TODO: NEED TO MAKE IT OPTIONAL TO ADD AN IMAGE LATER (perhaps use nil)
        guard let image = recipePreviewImage.image else {
            print("cannot unwrap the image")
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            displayMessage(title: "Error", message: "Image data could not be compressed")
            return
        }
        
//        let newRecipe = Recipe(name: name, description: description, prepTime: prepTime, cookTime: cookTime, difficulty: difficulty, image: image, ingredients: ingredients )
//        let _ = recipeDelegate?.addRecipe(newRecipe)
        print("add recipe btn pressed")
        //, directions: String?, protein: String?, carbohydrate: String?, fats: String?, calories: String?
        let _ = databaseController?.addRecipe(name: name, desc: description, prepTime: prepTime, cookTime: cookTime, difficulty: difficulty, imageData: imageData, ingredients: ingredients, directions: directions, protein: protein, carbohydrate: carbohydrate, fats: fats, calories: calories)
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Set up firebase //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // UITextView delegate for placeholder text //
        ingredientTextField.text = "List ingredients here"
        ingredientTextField.textColor = UIColor.lightGray
        ingredientTextField.returnKeyType = .done
        ingredientTextField.delegate = self
        
        // Keyboard settings //
        recipeDifficultyField.delegate = self
        recipeDifficultyField.keyboardType = .numberPad
        
        // Sets of the toolbar above the ingredient textView keyboard //
        ingredientToolBar()
        
    }
    
    // Adds bar btns above keyboard for ingredient textView //
    func ingredientToolBar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let oneQuarterButton = UIBarButtonItem(title: "1/4", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let oneThirdButton = UIBarButtonItem(title: "1/3", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let oneHalfButton = UIBarButtonItem(title: "1/2", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let twoThirdButton = UIBarButtonItem(title: "2/3", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let threeQuarterButton = UIBarButtonItem(title: "3/4", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let tspButton = UIBarButtonItem(title: "tsp", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let cupButton = UIBarButtonItem(title: "cup", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let mlButton = UIBarButtonItem(title: "ml", style: .plain, target: self, action: #selector(measurementButtonTapped))
        let gramsButton = UIBarButtonItem(title: "grams", style: .plain, target: self, action: #selector(measurementButtonTapped))
        
        toolbar.items = [oneQuarterButton, oneThirdButton, oneHalfButton, twoThirdButton, threeQuarterButton, tspButton, mlButton, gramsButton]
        
        ingredientTextField.inputAccessoryView = toolbar
    }
    
    
    @objc func doneButtonTapped() {
        ingredientTextField.resignFirstResponder()
    }
    // Adds the bar button text ontop of what the user has typed //
    @objc func measurementButtonTapped(sender: UIBarButtonItem) {
        if let text = ingredientTextField.text {
            ingredientTextField.text = text + sender.title!
        } else {
            ingredientTextField.text = sender.title
        }
    }
    
    // TextView Delegate: changes from placeholder text to user typed text //
    func textViewDidBeginEditing(_ textView: UITextView) {
        if ingredientTextField.text == "List ingredients here" {
            ingredientTextField.text = ""
            ingredientTextField.textColor = UIColor.black
        }
    }
    
    // UITextView delegate: Called for the textfield's delegate when user tap return. //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // UITextView delegate: Dismisses the keyboard //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // Set up the segmented controller //
    func setupUI() {
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    // SegmentedView controls the 4 Views //
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
    
    // UIImagePickerControllerDelegate -> This func is called when user has selected a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            recipePreviewImage.image = pickedImage
        }
        // Once image selected, dismiss ... Maybe here we need to store it elsewhere.
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
