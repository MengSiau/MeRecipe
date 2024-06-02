//
//  MyRecipeCollectionViewCell.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/4/2024.
//

import UIKit

class MyRecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var onReuse: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
        imageView.image = nil // Reset the image when cell is reused to avoid the "flickering image" bug.
    }
    
}
