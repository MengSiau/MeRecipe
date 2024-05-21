//
//  PushNotificationSettingsViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 21/5/2024.
//

import UIKit
import UserNotifications


struct NotificationInfo: Codable {
    let identifier: String
    let dateComponents: DateComponents
}

class PushNotificationSettingsViewController: UIViewController, DatabaseListener {
    
    var listenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?

    var selectedRecipe: Recipe?
    var selectedDate: Date?
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var currentSetTimeField: UILabel!
    
    lazy var appDelegate = {
        guard let appDelegate =  UIApplication.shared.delegate as?  AppDelegate else {
            fatalError("No AppDelegate")
        }
        return appDelegate
    }()
    
    
    @IBAction func saveBtn(_ sender: Any) {
        
        guard let selectedDate = selectedDate else {
            print("No date selected")
            displayMessage(title: "Input Error", message: "Please select a time")
            return
        }
        
        // Change the current set time textview //
        if let selectedTime = timeField.text {
            currentSetTimeField.text = "Current set time: \(selectedTime)"
        }
        
        guard appDelegate.notificationsEnabled else {
            print("Notifications not enabled")
            return
        }
        
        guard let selectedRecipe = selectedRecipe, let recipeName = selectedRecipe.name, let recipeCategory = selectedRecipe.category, let recipeId = selectedRecipe.id else {
            print("Unable to unwrwap recipe")
            return
        }
        
        // Create notification content //
        let content = UNMutableNotificationContent()
        
        content.title = "\(recipeCategory) time!"
        content.body = "Time to cook \(recipeName)."
        let identifier = recipeCategory + recipeId
        
        // Create notification contents using date //
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: selectedDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Formats time to be readable //
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let notificationTime = dateFormatter.string(from: selectedDate)
    
        
        UNUserNotificationCenter.current().add(request){ (error) in
            if error == nil {
                print("save notification func called")
            } else {
                print("Failed to schedule notification: \(String(describing: error))")
            }
        }
        
        print("Notification scheduled at \(dateComponents)") // TODO: DO a pop up here
        displayMessage(title: "Alarm Set!", message: "Notification scheduled at \(notificationTime)")
        
        // Save the notification alarm time to recipe //
        databaseController?.editRecipeNotificationTime(recipeToEdit: selectedRecipe, notificationTime: notificationTime)
    }
    

    @IBAction func deleteTimerBtn(_ sender: Any) {
        guard  let selectedRecipe = selectedRecipe, let recipeCategory = selectedRecipe.category, let recipeId = selectedRecipe.id else {
            print("Unable to unwrwap recipe")
            return
        }
        
        // Removes the pending notification //
        let toRemoveNotificationIdentifier = recipeCategory + recipeId
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [toRemoveNotificationIdentifier])
        
        // Deletes the notification time //
        databaseController?.editRecipeNotificationTime(recipeToEdit: selectedRecipe, notificationTime: "")
        
        // Update the view
        timeField.text = ""
        currentSetTimeField.text = "No Time Currently Selected"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIREBASE //
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        guard let selectedRecipe = selectedRecipe else {
            print("cannot find selected recipe")
            return
        }
        
        // Preset labels and fields with values //
        timeField.text = selectedRecipe.notificationTime
        if selectedRecipe.notificationTime == "" {
            currentSetTimeField.text = "No Time Currently Selected"
        } else {
            currentSetTimeField.text = selectedRecipe.notificationTime
        }
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        
        timeField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        timeField.inputAccessoryView = toolbar
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        // Store and display selected time //
        timeField.text = dateFormatter.string(from: datePicker.date)
        selectedDate = datePicker.date
        
    }
    
    @objc func donePressed() {
        timeField.resignFirstResponder()
    }
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {
        
    }
    
    func onAllRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        
    }
    
    func onAllIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
