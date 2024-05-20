//
//  DinnerMealTableViewCell.swift
//  MeRecipe
//
//  Created by Meng Siau on 19/5/2024.
//

import UIKit

class DinnerMealTableViewCell: UITableViewCell {

    @IBOutlet weak var mealImage: UIImageView!

    
    @IBOutlet weak var mealNameText: UILabel!
    
    @IBOutlet weak var timeText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
