//
//  AddMealViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 19/5/2024.
//

import UIKit

class AddMealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var listOfRecipe: [Recipe] = []
    var categoryType: String = "breakfast"
    
    let breakfastSegmentIndex = 0
    let lunchSegmentIndex = 1
    let dinnerSegmentIndex = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemGray6
        
        // Adds category selection functionality to the segmented controller //
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        // Adds the information hint below segmented controler //
        setUpInfoHeading()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Setup the tableView //
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "recipeCell")
        tableView.backgroundColor = UIColor.systemGray6
    }
    
    
    // Programatically adds a hint message below navigation title //
    private func setUpInfoHeading() {
        let headerView = UIView()
        let infoLabel = UILabel()
        infoLabel.text = "Select a meal to add to a category"
        infoLabel.textColor = .gray
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        let infoImageView = UIImageView(image: UIImage(systemName: "info.circle"))
        infoImageView.tintColor = .gray
        let stackView = UIStackView(arrangedSubviews: [infoImageView, infoLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        headerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12)
        ])
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25)
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - TableView methods //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecipe.count
    }
    
    // Cells only have the name of the recipe //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
        
        let selectedRecipe = listOfRecipe[indexPath.row]
        cell.textLabel?.text = selectedRecipe.name
        
        return cell
    }
    
    // Selecting a recipe will add it to a category. Pop back to prev view //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRecipe = listOfRecipe[indexPath.row]
        databaseController?.editRecipeCategory(recipeToEdit: selectedRecipe, category: categoryType)
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: false)
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        // If a recipe does not have a category, add it to the tableview for users to select from //
        for recipe in recipes {
            if recipe.category == "" {
                listOfRecipe.append(recipe)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // SegmentedView controls the 3 Views //
    @objc func segmentedControlValueChanged() {
        if segmentController.selectedSegmentIndex == breakfastSegmentIndex {
            categoryType = "breakfast"
        } else if segmentController.selectedSegmentIndex == lunchSegmentIndex {
            categoryType = "lunch"
        } else if segmentController.selectedSegmentIndex == dinnerSegmentIndex {
            categoryType = "dinner"
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
