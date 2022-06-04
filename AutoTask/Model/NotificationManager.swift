//
//  NotificationManager.swift
//  AutoTask
//
//  Created by Justin Wong on 5/31/22.
//

import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    //Singleton is requierd because of delegate
    static let shared: NotificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()

    private override init(){
        super.init()
        //This assigns the delegate
        notificationCenter.delegate = self
    }
    
    func scheduleUNCalendarNotificationTrigger(title: String, body: String, dateComponents: DateComponents, identifier: String, repeats: Bool = false){
//        print(#function)
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func scheduleUNTimeIntervalNotificationTrigger(title: String, body: String, timeInterval: TimeInterval, identifier: String, repeats: Bool = false){
        print(#function)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
    }
    ///Schedules `count` number of monthly notifications that occur `xDaysBefore` the `baseDate`
    func scheduleBasedOnDaysBeforeDate(title: String, body: String, baseDate: Date, xDaysBefore: Int, count: Int, identifier: String){
        print(#function)
        var nextBaseDate: Date = baseDate
        
        for n in 1...count{
            
            guard let triggerDate: Date = Calendar.current.date(byAdding: .day, value: -xDaysBefore, to: nextBaseDate) else{
                return
            }
            let components: DateComponents = Calendar.current.dateComponents([.month,.day, .hour,.minute,.second], from: triggerDate)
            let id = identifier.appending(" \(n)")
            scheduleUNCalendarNotificationTrigger(title: title, body: body, dateComponents: components, identifier: id)
            //OR if you want specific seconds
            //let interval = Calendar.current.dateComponents([.second], from: Date(), to: triggerDate).second ?? 1
            
            //scheduleUNTimeIntervalNotificationTrigger(title: title, body: body, timeInterval: TimeInterval(interval), identifier: id)
            
            let next = Calendar.current.date(byAdding: .month, value: 1, to: nextBaseDate)
            
            if next != nil{
                
                nextBaseDate = next!
            }else{
                print("next == nil")
                return
            }
        }
        self.printNotifications()
        
    }
    func requestAuthorization() {
        print(#function)
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Access Granted!")
            } else {
                print("Access Not Granted")
            }
        }
    }

    func deleteAllPendingNotifications(){
        print(#function)
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func deleteSpecificPendingNotifications(for identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    ///Prints to console schduled notifications
    func printNotifications(){
        print(#function)
        notificationCenter.getPendingNotificationRequests { request in
            print("UNTimeIntervalNotificationTrigger Pending Notification")
            for req in request{
                if req.trigger is UNTimeIntervalNotificationTrigger{
                    print((req.trigger as! UNTimeIntervalNotificationTrigger).nextTriggerDate()?.description ?? "invalid next trigger date")
                }
            }
            print("UNCalendarNotificationTrigger Pending Notification")
            for req in request{
                if req.trigger is UNCalendarNotificationTrigger{
                    print((req.trigger as! UNCalendarNotificationTrigger).nextTriggerDate()?.description ?? "invalid next trigger date")
                }
            }
        }
    }
    ///Prints to console delivered notifications
    func printDeliveredNotifications(){
        print(#function)
        notificationCenter.getDeliveredNotifications { request in
            for req in request{
                print(req)
            }
        }
    }
    //MARK: UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.banner)
    }
}
