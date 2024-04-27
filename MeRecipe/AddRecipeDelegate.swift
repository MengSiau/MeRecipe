//
//  AddRecipeDelegate.swift
//  MeRecipe
//
//  Created by Meng Siau on 24/4/2024.
//

import Foundation


protocol AddRecipeDelegate: AnyObject {
    func addRecipe(_ newRecipe: Recipe) -> Bool
}
