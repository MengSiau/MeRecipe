//
//  AcknowledgementViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 25/5/2024.
//

import UIKit

class AcknowledgementViewController: UIViewController {
    
    @IBOutlet weak var acknowledgementText: UILabel!
    
    var textToDisplay = """
This app utilises the following third-party code, use of which is hereby acknowledged.

Firebase (FirebaseAuth, FirebaseFirestore)

Copyright 2017-2024 Google

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at:
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

API Ninja Nutrition API

Data provided by the Nutrition API from API Ninja.

"""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        acknowledgementText.text = textToDisplay
        
        // Set the background color to a light gray
        self.view.backgroundColor = UIColor.systemGray6
        
        // Set the text color to dark gray
        acknowledgementText.textColor = UIColor.darkGray
        
        // Set the text to display
        acknowledgementText.text = textToDisplay
        
        // Adjust the label's font size and style if needed
        acknowledgementText.font = UIFont.systemFont(ofSize: 16)
        
        // Optionally, you can adjust the number of lines and text alignment
        acknowledgementText.numberOfLines = 0
        acknowledgementText.textAlignment = .left

    }
}
