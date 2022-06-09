//
//  NotificationManager.swift
//  AutoTask
//
//  Created by Justin Wong on 5/31/22.
//

import UserNotifications
import CoreData

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    //Singleton is requierd because of delegate
    static let shared: NotificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()

    private override init(){
        super.init()
        //This assigns the delegate
        notificationCenter.delegate = self
    }
    
    func scheduleNotificationforReminderOrDeadline(for taskAction: TaskAction, in task: Task) {
        //create/schedule user notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        //clear previous pending notification if there is one
        deleteSpecificPendingNotifications(for: [taskAction.identifier])
        
        let components = taskAction.dateAndTime.get(.day, .month, .year)
        if let day = components.day, let month = components.month, let year = components.year {
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: taskAction.dateAndTime)
            let minute = calendar.component(.minute, from: taskAction.dateAndTime)
            
            var newDateComponent = DateComponents()
            newDateComponent.day = day
            newDateComponent.month = month
            newDateComponent.year = year
            newDateComponent.hour = hour
            newDateComponent.minute = minute
          
            scheduleUNCalendarNotificationTrigger(title: task.title, body: taskAction.content, dateComponents: newDateComponent, identifier: taskAction.identifier)
        }
    }
    
    private func scheduleUNCalendarNotificationTrigger(title: String, body: String, dateComponents: DateComponents, identifier: String, repeats: Bool = false){
//        print(#function)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
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
        //fetch all Task Actions
        let taskActionsFetchRequest: NSFetchRequest<TaskAction> = TaskAction.fetchRequest()
        taskActionsFetchRequest.predicate = NSPredicate(format: "identifier_ == %@", notification.request.identifier)
        let context = PersistenceController.shared.container.viewContext
        do {
            let objects = try context.fetch(taskActionsFetchRequest)
            if let firstTaskAction = objects.first {
                firstTaskAction.isConfirmed = true
                try? PersistenceController.shared.container.viewContext.save()
            }
            print(objects)
        } catch {
            print(error.localizedDescription)
        }
        completionHandler(.banner)
    }
}
