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
    
    // Trigger the setDarkMode() func when switch is toggled //
    @IBAction func cellSwitchAction(_ sender: UISwitch) {
        let isDarkModeEnabled = sender.isOn
        UserDefaults.standard.set(isDarkModeEnabled, forKey: "isDarkModeEnabled")
        setDarkMode(isDarkModeEnabled)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Ensure we sync the dark mode settings from user defaults so the switch is orientated correctly //
        let isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        cellSwitch.setOn(isDarkModeEnabled, animated: false)
        setDarkMode(isDarkModeEnabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Helper func that enables/disables dark mode //
    private func setDarkMode(_ isDarkMode: Bool) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.toggleDarkMode(isDarkMode)
        }
    }
}
