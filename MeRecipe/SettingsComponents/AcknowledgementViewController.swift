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

Firebase (FirebaseAuth, FirebaseFirestore, FirebaseStorage)

API Ninja Nutrition API (Data provided by the Nutrition API from API Ninja + sample prompt code given to call a request for swift.)

Copyright 2017-2024 Google

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at:
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
"""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Customizing how the acknowledgement text looks like //
        self.view.backgroundColor = UIColor.systemGray6
        acknowledgementText.textColor = UIColor.darkGray
        acknowledgementText.font = UIFont.systemFont(ofSize: 16)
        
        acknowledgementText.numberOfLines = 0
        acknowledgementText.textAlignment = .left

        acknowledgementText.text = textToDisplay
    }
}
