//
//  DeleteDataTableViewCell.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/5/2024.
//

import UIKit

class DeleteDataTableViewCell: UITableViewCell, DatabaseListener {
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
    
    var listOfRecipe: [Recipe] = []

    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellBtn: UIButton!
    
    @IBAction func cellBtnAction(_ sender: Any) {    
        
        guard let viewController = self.findViewController() else {
            print("Unable to find view controller to present alert")
            return
        }
        
        let alertController = UIAlertController(title: "Warning", message: "This will delete all recipe data permanently. Are you sure you want to proceed?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            self.deleteAllRecipe()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func deleteAllRecipe() {
        for toDeleteRecipe in listOfRecipe {
            print("deleted one recipe")
            databaseController?.deleteRecipe(recipe: toDeleteRecipe)
        }
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {}
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        listOfRecipe = recipes
        print(listOfRecipe)
    }
    
    
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {}
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        
        return nil
    }

}
