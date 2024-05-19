//
//  MealSchedulerTableViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 19/5/2024.
//

import UIKit

class MealSchedulerTableViewController: UITableViewController {
    
//    var listenerType = ListenerType.ingredient
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_BREAKFAST = 0
    let SECTION_LUNCH = 1
    let SECTION_DINNER = 2
    
    let CELL_BREAKFAST = "breakfastCell"
    let CELL_LUNCH = "lunchCell"
    let CELL_DINNER = "dinnerCell"
    
    // List of Recipe so that user can choose which one to add
    // breakfast, lunch, dinner. Add recipe means to tag recipe with tag. Loop through list of recipe to find the one with the tag.
    var recipeList: [Recipe] = []
    var testList = ["test1", "test2", "test3"]
    
    var breakfastList: [String] = []
    var lunchList: [String] = []
    var dinnerList: [String] = []
    
    @IBAction func addMealBtn(_ sender: Any) {
        performSegue(withIdentifier: "addMealSegue", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_BREAKFAST:
                return testList.count
            case SECTION_LUNCH:
                return testList.count
            case SECTION_DINNER:
                return dinnerList.count
            default:
                return 0
        }
        
//        switch section {
//            case SECTION_BREAKFAST:
//                return breakfastList.count
//            case SECTION_LUNCH:
//                return lunchList.count
//            case SECTION_DINNER:
//                return dinnerList.count
//            default:
//                return 0
//        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SECTION_BREAKFAST {
            let cell = tableView.dequeueReusableCell(withIdentifier: "breakfastCell", for: indexPath) as! BreakfastMealTableViewCell
            
            let meal = testList[indexPath.row]
            cell.mealNameText.text = meal
            cell.timeText.text = "asdasdasdasd"
            return cell
            
        } else if indexPath.section == SECTION_LUNCH {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LUNCH, for: indexPath) as! LunchMealTableViewCell
            
            let meal = testList[indexPath.row]
            cell.mealNameText.text = meal
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DINNER, for: indexPath) as! DinnerMealTableViewCell
            
            let meal = testList[indexPath.row]
            cell.mealNameText.text = meal
            return cell
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
