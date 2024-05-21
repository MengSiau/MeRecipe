//
//  BreakfastMealTableViewCell.swift
//  MeRecipe
//
//  Created by Meng Siau on 19/5/2024.
//

import UIKit



class BreakfastMealTableViewCell: UITableViewCell {

    @IBOutlet weak var mealNameText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0 // Return the desired height
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
