//
//  TabController.swift
//  MeRecipe
//
//  Created by Meng Siau on 25/5/2024.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTabs()

    }
    
    private func setUpTabs() {
        let home = self.createNav(title: "home", image: UIImage(systemName: "house"), vc: MyRecipeCollectionViewController())
        let shop = self.createNav(title: "shop", image: UIImage(systemName: "house"), vc: ShoppingListTableViewController())
        
        self.setViewControllers([home, shop], animated: true)
    }
    
    private func createNav(title: String, image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        return nav
    }


}
