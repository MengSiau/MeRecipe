//
//  NightmodeTableViewCell.swift
//  MeRecipe
//
//  Created by Meng Siau on 23/5/2024.
//

import UIKit

class NightmodeTableViewCell: UITableViewCell {

    @IBOutlet weak var cellHeader: UILabel!
  
    @IBOutlet weak var cellSwitch: UISwitch!
    
    
    @IBAction func cellSwitchAction(_ sender: UISwitch) {
    
        let isDarkModeEnabled = sender.isOn
         UserDefaults.standard.set(isDarkModeEnabled, forKey: "isDarkModeEnabled")
         setDarkMode(isDarkModeEnabled)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        cellSwitch.setOn(isDarkModeEnabled, animated: false)
        setDarkMode(isDarkModeEnabled)
        print(isDarkModeEnabled)
        
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func setupSwitch() {
        let isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        
        setDarkMode(isDarkModeEnabled)
    }
    
    private func setDarkMode(_ isDarkMode: Bool) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.toggleDarkMode(isDarkMode)
        }
    }
}
