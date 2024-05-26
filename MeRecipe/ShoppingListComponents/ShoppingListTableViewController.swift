//
//  ShoppingListTableViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 14/5/2024.
//

import UIKit

class ShoppingListTableViewController: UITableViewController, DatabaseListener, UISearchBarDelegate {
    
    var listenerType = ListenerType.ingredient
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_TOBUY = 0
    let SECTION_BOUGHT = 1
    let SECTION_INFO = 2
    
    let CELL_TOBUY = "toBuyCell"
    let CELL_BOUGHT = "boughtCell"
    let CELL_INFO = "infoCell"
    
    var toBuyList: [Ingredient] = []
    var boughtList: [Ingredient] = []
    
    

    
    @IBAction func addIngredientBtn(_ sender: Any) {
        print("btn pressed")
        databaseController?.addIngredient(name: "chow")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        self.tableView.backgroundColor = UIColor.systemGray6
        navigationItem.title = "Shoppling List"
        
        // Search Bar to add Ingredients manually //
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Add Ingredient Name Here"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
        // Programatically adds a hint message below navigation title //
        let headerView = UIView()
        
        let infoLabel = UILabel()
        infoLabel.text = "Press the plus button to add ingredients."
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
        
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 15)
        tableView.tableHeaderView = headerView
        
//        // TOOLBAR //
//        let homeBtn = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(homeButtonTapped))
//        let shoppingListBtn = UIBarButtonItem(image: UIImage(systemName: "cart"), style: .plain, target: self, action: #selector(shoppingListBtnTapped))
//        let mealScheduleBtn = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(mealScheduleBtnTapped))
//        let settingsBtn = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        
//        // Set the toolbar items
//        self.toolbarItems = [homeBtn, flexibleSpace, shoppingListBtn, flexibleSpace, mealScheduleBtn, flexibleSpace, settingsBtn]
        
    }
    
//    @objc func homeButtonTapped() {navigationController?.popViewController(animated: true)}
//    @objc func shoppingListBtnTapped() {}
//    @objc func mealScheduleBtnTapped() {performSegue(withIdentifier: "mealSchedulerSegue", sender: self)}
//    @objc func settingsButtonTapped() {performSegue(withIdentifier: "settingsSegue", sender: self)}
    
    
    // Adds the ingredient from the search bar //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchedText = searchBar.text {
            databaseController?.addIngredient(name: searchedText)
            searchBar.text = ""
        }
        searchBar.resignFirstResponder()
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        toBuyList = ingredients
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Removes checked Ingredients //
        removeCheckedIngredients()
        databaseController?.removeListener(listener: self)
        
        self.navigationController?.isToolbarHidden = true
    }
    
    // Removes checked Ingredients from Firebaes //
    func removeCheckedIngredients() {
        for checkedIngredient in boughtList {
            databaseController?.deleteIngredient(ingredient: checkedIngredient)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_TOBUY:
                return toBuyList.count
            case SECTION_BOUGHT:
                return boughtList.count
            case SECTION_INFO:
                return 1
            default:
                return 0
        }
    }
    
    // Handles the ToBuy, Checked and Info Sections in TableView //
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_TOBUY {
            let toBuyCell = tableView.dequeueReusableCell(withIdentifier: CELL_TOBUY, for: indexPath) as! ToBuyTableViewCell
            let toBuyIngredient = toBuyList[indexPath.row]
            toBuyCell.ingredientText.text = toBuyIngredient.name
            
            return toBuyCell
        }
        else if indexPath.section == SECTION_BOUGHT{
            let boughtCell = tableView.dequeueReusableCell(withIdentifier: CELL_BOUGHT, for: indexPath) as! BoughtTableViewCell
            let boughtIngredient = boughtList[indexPath.row]
            boughtCell.ingredientText.text = boughtIngredient.name
            
            // Grey text and strikeout text //
            boughtCell.textLabel?.textColor = .gray
            boughtCell.textLabel?.attributedText = NSAttributedString(string: boughtIngredient.name ?? "Cannot Display Ingredient", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            
            return boughtCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            
            let toBuyCount = toBuyList.count
            let boughtCount = boughtList.count
            let totalCount = toBuyCount + boughtCount
            
            infoCell.textLabel?.text = "Ingredients Bought: [\(boughtCount) / \(totalCount)]"
            return infoCell
        }
    }
    
    // Responsible for moving ingredients back and forth from ToBuy and Checked sections //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_TOBUY {
            let selectedIngredient = toBuyList[indexPath.row]
            boughtList.append(selectedIngredient)
            toBuyList.remove(at: indexPath.row)
            tableView.reloadData()
        } else if indexPath.section == SECTION_BOUGHT {
            let selectedIngredient = boughtList[indexPath.row]
            toBuyList.append(selectedIngredient)
            boughtList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
            case SECTION_TOBUY:
                return "Ingredients To Buy:"
            case SECTION_BOUGHT:
                return "Checked: "
            case SECTION_INFO:
                return "Status"
            default:
                return nil
        }
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


