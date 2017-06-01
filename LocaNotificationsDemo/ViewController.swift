//
//  ViewController.swift
//  LocalNotificationsDemo
//
//  Created by Marcelo Mogrovejo on 5/29/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    let notificationCenter = UNUserNotificationCenter.current()
    var badgeCount: Int = 0
    let application = UIApplication.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**************************************************************
         * Push Notifications
         *
         *
         **************************************************************/
        
        // Register the notifications and prompt the user to accept or deny them
        notificationCenter.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (granted: Bool, error: Error?) in })
        
        notificationCenter.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func scheduleNotification(_ sender: Any) {
        
        // Register the notification categories (Without a category, notifications are displayed without any custom actions or configuration options)
        let generalCategory = UNNotificationCategory(identifier: "GENERAL_CATEGORY", actions: [], intentIdentifiers: [], options: .customDismissAction)
        
        // Create the custom actions for a timer expired category.
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Snooze", options: UNNotificationActionOptions(rawValue: 0))
        let stopAction = UNNotificationAction(identifier: "STOP_ACTION", title: "Stop", options: .foreground)
        let expiredCategory = UNNotificationCategory(identifier: "TIMER_EXPIRED", actions: [snoozeAction, stopAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Retister categories
        notificationCenter.setNotificationCategories([generalCategory, expiredCategory])
        
        /**************************************************************
         * Local Notifications
         *
         * 1. To inform the user he is reaching a specific location or
         * 2. To inform the user he is reaching a specific time
         *
         **************************************************************/
        
        // Create and configure a local notification
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Wake up!", arguments: nil)
        content.subtitle = NSString.localizedUserNotificationString(forKey: "Time to get out of the bed", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Rise and shine! It's morning time!", arguments: nil)
        content.categoryIdentifier = "TIMER_EXPIRED"
        content.sound = UNNotificationSound.default()
        content.badge = badgeCount + 1 as NSNumber // set badge
        
        // Configure the trigger for a 10am wakeup.
        var dateInfo = DateComponents()
        
        let time = getCurrentTime(hours: true, minutes: true, seconds: false)
        
        if hourTextField.text != "" {
            dateInfo.hour = Int(hourTextField.text!)
        } else {
            dateInfo.hour = time["hours"]!
            hourTextField.text = "\(String(describing: time["hours"]!))"
        }
        
        if minuteTextField.text != "" {
            dateInfo.minute = Int(minuteTextField.text!)
        } else {
            dateInfo.minute = time["minutes"]! + 2
            minuteTextField.text = "\(String(describing: time["minutes"]! + 2))"
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // Create the request object
        let request = UNNotificationRequest(identifier: "MorningAlarmId", content: content, trigger: trigger)
        
        // Schedule the request
        notificationCenter.add(request) { (error: Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
        
        // Label message
        messageLabel.text = "The notification was setted to \(hourTextField.text!):\(minuteTextField.text!)"
    }
    
    // When user select an action from the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.content.categoryIdentifier == "TIMER_EXPIRED" {
            // Handle the actions for the expired timer
            if response.actionIdentifier == "SNOOZE_ACTION" {
                // Invalidate the old timer and create a new one...
                print("RESPONSE FOR SNOOZING ALARM....")
            } else if response.actionIdentifier == "STOP_ACTION" {
                // Invalidate the timer...
                print("RESPONSE FOR STOPING THE TIMER...")
            }
        }
        // Handle default system actions
        else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // User dismiss the notification without performing any custom action
            print("USER DISMISSED THE NOTIFICATION WITHOUT TAKING ACTION")
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // User launched the app
            print("USER LAUNCHED THE APP")
        }
        // Handle actions for other notification types
        else {
            
        }
        
    }
    
    // When app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let content = notification.request.content
        if content.badge != nil {
            badgeCount = content.badge as! Int
        }
        
        application.applicationIconBadgeNumber = badgeCount
        
    }
    
    // MARK: private methods
    
    private func getCurrentTime(hours: Bool, minutes: Bool, seconds: Bool) -> Dictionary<String, Int> {
        let date = Date()
        let calendar = Calendar.current
        
        var returnedDict: Dictionary<String, Int> = ["": 0]
        
        if hours {
            returnedDict["hours"] = calendar.component(.hour, from: date)
        }
        
        if minutes {
            returnedDict["minutes"] = calendar.component(.minute, from: date)
        }
        
        if seconds {
            returnedDict["seconds"] = calendar.component(.second, from: date)
        }
        
        return returnedDict
    }

}

