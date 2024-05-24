//
//  SettingsTableViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/5/2024.
//

import UIKit

class SettingsTableViewController: UITableViewController, DatabaseListener {
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
    var listOfRecipe: [Recipe] = []
    
    let SECTION_NIGHTMODE = 0
    let SECTION_DELETEDATA = 1
    let SECTION_ACKNOWLEDGEMENT = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.backgroundColor = UIColor.systemGroupedBackground

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_NIGHTMODE:
                return 1
            case SECTION_DELETEDATA:
                return 1
            case SECTION_ACKNOWLEDGEMENT:
                return 1
            default:
                return 0
        }
    }

    // Populate the tableview with the required cell types //
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_NIGHTMODE {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nightmodeCell", for: indexPath) as! NightmodeTableViewCell
            return cell
        } else if indexPath.section == SECTION_DELETEDATA  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteDataCell", for: indexPath) as! DeleteDataTableViewCell
            cell.listOfRecipe = listOfRecipe // Pass Recipes to delete to cell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "acknowledgementCell", for: indexPath) as! AcknowledgementTableViewCell
            return cell
        }
        
    }
    
    // Creates headers for each section //
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
            case SECTION_NIGHTMODE:
                return "Appearance"
            case SECTION_DELETEDATA:
                return "Data Control"
            case SECTION_ACKNOWLEDGEMENT:
                return "Third Party Libraries"
            default:
                return nil
        }
    }
    
    // Footer description of the settings cells //
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case SECTION_NIGHTMODE:
            return "This will apply to the whole app's appeance"
        case SECTION_DELETEDATA:
            return "WARNING: Permanently deletes all recipes"
        case SECTION_ACKNOWLEDGEMENT:
            return nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as? UITableViewHeaderFooterView
        footer?.textLabel?.font = UIFont.systemFont(ofSize: 14) // Adjust the font size as needed
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
    }
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_ACKNOWLEDGEMENT {
            performSegue(withIdentifier: "acknowledgementSegue", sender: self)
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
