//
//  MealSchedulerTableViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 19/5/2024.
//

import UIKit

class MealSchedulerTableViewController: UITableViewController, DatabaseListener {
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_BREAKFAST = 0
    let SECTION_LUNCH = 1
    let SECTION_DINNER = 2
    
    let CELL_BREAKFAST = "breakfastCell"
    let CELL_LUNCH = "lunchCell"
    let CELL_DINNER = "dinnerCell"
    
    // List of Recipe so that user can choose which one to add
    // breakfast, lunch, dinner. Add recipe means to tag recipe with tag. Loop through list of recipe to find the one with the tag.
    var listOfRecipe: [Recipe] = []
    var selectedRecipeForNotification: Recipe?
    var testList = ["test1", "test2", "test3"]
    
    var breakfastList: [Recipe] = []
    var lunchList: [Recipe] = []
    var dinnerList: [Recipe] = []
    
    @IBAction func addMealBtn(_ sender: Any) {
        performSegue(withIdentifier: "addMealSegue", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.systemGray6

        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Programatically adds a hint message below navigation title //
        let headerView = UIView()
        
        let infoLabel = UILabel()
        infoLabel.text = "Tap the meal to schedule an alarm"
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
//        
    }
    
//    @objc func homeButtonTapped() {navigationController?.popViewController(animated: true)}
//    @objc func shoppingListBtnTapped() {performSegue(withIdentifier: "shoppingListSegue", sender: self)}
//    @objc func mealScheduleBtnTapped() {}
//    @objc func settingsButtonTapped() {performSegue(withIdentifier: "settingsSegue", sender: self)}
    
    
    func sortRecipeByCategory(listOfRecipe: [Recipe]) {
        for recipe in listOfRecipe {
            if recipe.category == "breakfast" && !breakfastList.contains(where: { $0.name == recipe.name }){
                breakfastList.append(recipe)
            } else if recipe.category == "lunch" && !lunchList.contains(where: { $0.name == recipe.name }){
                lunchList.append(recipe)
            } else if recipe.category == "dinner" && !dinnerList.contains(where: { $0.name == recipe.name }){
                dinnerList.append(recipe)
            }
        }
    }
    
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    // TODO: ISSUE HERE IS THAT POPPING BACK CAUSES BREAKFAST LIST TO OVERPOPULATE
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
        print("onchange recipelist", listOfRecipe)
        sortRecipeByCategory(listOfRecipe: listOfRecipe) 
        print("onchange breakList", breakfastList)
    }
    
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_BREAKFAST:
                return breakfastList.count
            case SECTION_LUNCH:
                return lunchList.count
            case SECTION_DINNER:
                return dinnerList.count
            default:
                return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SECTION_BREAKFAST {
            let cell = tableView.dequeueReusableCell(withIdentifier: "breakfastCell", for: indexPath) as! BreakfastMealTableViewCell
            
            let selectedMeal = breakfastList[indexPath.row]
            
            // Set meal name + notification alarm time //
            cell.mealNameText.text = selectedMeal.name
            guard let notificationTime = selectedMeal.notificationTime else {
                print("Unable to unwrap notification time")
                return cell
            }
            
            if notificationTime == "" {
                cell.timeText.text = "⏰ Alarm: " + "N/A"
            } else {
                cell.timeText.text = "⏰ Alarm: " + notificationTime
            }
           
            
            // Get Recipe's image file name and attempt to load it locally from files //
            guard let filename = selectedMeal.imageFileName else {
                print("cannot unwrap image file name")
                return cell
            }
            if let localImage = loadImageFromLocal(filename: filename) {
                cell.mealImage.image = localImage
                return cell
            }
            return cell
            
        } else if indexPath.section == SECTION_LUNCH {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LUNCH, for: indexPath) as! LunchMealTableViewCell
            
            let selectedMeal = lunchList[indexPath.row]
            
            // Set meal name + notification alarm time //
            cell.mealNameText.text = selectedMeal.name
            guard let notificationTime = selectedMeal.notificationTime else {
                print("Unable to unwrap notification time")
                return cell
            }
            
            if notificationTime == "" {
                cell.timeText.text = "⏰ Alarm: " + "N/A"
            } else {
                cell.timeText.text = "⏰ Alarm: " + notificationTime
            }
            
            // Get Recipe's image file name and attempt to load it locally from files //
            guard let filename = selectedMeal.imageFileName else {
                print("cannot unwrap image file name")
                return cell
            }
            if let localImage = loadImageFromLocal(filename: filename) {
                cell.mealImage.image = localImage
                return cell
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DINNER, for: indexPath) as! DinnerMealTableViewCell
            
            let selectedMeal = dinnerList[indexPath.row]
            
            // Set meal name + notification alarm time //
            cell.mealNameText.text = selectedMeal.name
            guard let notificationTime = selectedMeal.notificationTime else {
                print("Unable to unwrap notification time")
                return cell
            }
            
            if notificationTime == "" {
                cell.timeText.text = "⏰ Alarm: " + "N/A"
            } else {
                cell.timeText.text = "⏰ Alarm: " + notificationTime
            }
            
            // Get Recipe's image file name and attempt to load it locally from files //
            guard let filename = selectedMeal.imageFileName else {
                print("cannot unwrap image file name")
                return cell
            }
            if let localImage = loadImageFromLocal(filename: filename) {
                cell.mealImage.image = localImage
                return cell
            }
            
            return cell
        }
    }
    
    func loadImageFromLocal(filename: String) -> UIImage? {
        // Get the document directory path
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        // Create a file URL for the image
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        // Load image from file URL
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image from local storage: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
            case SECTION_BREAKFAST:
                return "Breakfast"
            case SECTION_LUNCH:
                return "Lunch "
            case SECTION_DINNER:
                return "Dinner"
            default:
                return nil
        }
    }

    
    //
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_BREAKFAST {
            selectedRecipeForNotification = breakfastList[indexPath.row]
            performSegue(withIdentifier: "notificationSegue", sender: self)
        } else if indexPath.section == SECTION_LUNCH {
            selectedRecipeForNotification = lunchList[indexPath.row]
            performSegue(withIdentifier: "notificationSegue", sender: self)
        } else if indexPath.section == SECTION_DINNER {
            selectedRecipeForNotification = dinnerList[indexPath.row]
            performSegue(withIdentifier: "notificationSegue", sender: self)
        }
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var recipeToRemove: Recipe?
            
            tableView.beginUpdates()
            
            switch indexPath.section {
            case SECTION_BREAKFAST:
                recipeToRemove = breakfastList[indexPath.row]
                breakfastList.remove(at: indexPath.row)
                
            case SECTION_LUNCH:
                recipeToRemove = lunchList[indexPath.row]
                lunchList.remove(at: indexPath.row)
                
            case SECTION_DINNER:
                recipeToRemove = dinnerList[indexPath.row]
                dinnerList.remove(at: indexPath.row)
                
            default:
                return
            }
            
            // Remove Recipe from tableView + Reset Category + Remove any pending notification //
            guard let recipeToRemove = recipeToRemove, let recipeCategory = recipeToRemove.category, let recipeId = recipeToRemove.id else {
                print("Unable to unwrwap recipe")
                return
            }
            
            // Removes Recipe Category //
            databaseController?.editRecipeCategory(recipeToEdit: recipeToRemove, category: "")
            
            // Removes the pending notification //
            let toRemoveNotificationIdentifier = recipeCategory + recipeId
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [toRemoveNotificationIdentifier])
            
            // Deletes the notification time //
            databaseController?.editRecipeNotificationTime(recipeToEdit: recipeToRemove, notificationTime: "")
            
            print("Breakfast List Count After Removal: \(breakfastList.count)")
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notificationSegue" {
              if let destination = segue.destination as? PushNotificationSettingsViewController {
                  destination.selectedRecipe = selectedRecipeForNotification
              }
          }
      }
    
    }
    


