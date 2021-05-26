//
//  Database.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//
import UIKit
import CoreData

protocol DatabaseReadable {
    //func getQuotes() -> [Currency]
}

protocol DatabaseSavable {
    func saveUsers(_ userResponses: [UserResponse])
    func saveMessage(message:String, fromId: Int, toId: Int, date: Date)
    func saveUserDetail(userResponse: UserResponse)
}

class Database: DatabaseReadable, DatabaseSavable {

    static let shared = Database()

    ///Initially fills our database with a local json if needed
    func inititalSetup() {}


    func saveUsers(_ userResponses: [UserResponse]) {
        //I don't want to check for update/insert so I delete all entries before
        let managedContext = self.persistentContainer.viewContext
        for ur in userResponses {
            let e = user(forId: ur.id) ?? UserEntity(context: managedContext)
            e.id = Int64(ur.id)
            e.nodeId = ur.node_id
            e.login = ur.login
            e.avatarUrl = ur.avatar_url
        }
        self.saveContext()
    }

    
    func saveUserDetail(userResponse: UserResponse) {
        self.deleteAllUsers()

        let managedContext = self.persistentContainer.viewContext
        let e = user(forId: userResponse.id) ?? UserEntity(context: managedContext)
        e.id = Int64(userResponse.id)
        e.nodeId = userResponse.node_id
        e.login = userResponse.login
        e.avatarUrl = userResponse.avatar_url
        e.name = userResponse.name
        e.followers = Int64(userResponse.followers ?? 0)
        e.following = Int64(userResponse.following ?? 0)
        e.isMe = true
        self.saveContext()
    }

    func me() -> UserEntity? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let pred = NSPredicate(format: "isMe == true")
        request.predicate = pred
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.persistentContainer.viewContext.fetch(request)
            return result.first as? UserEntity
        } catch {
            print("Failed")
        }
        return nil
    }

    func user(forId id: Int) -> UserEntity? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let pred = NSPredicate(format: "id == \(id)")
        request.predicate = pred
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.persistentContainer.viewContext.fetch(request)
            return result.first as? UserEntity
        } catch {
            print("Failed")
        }
        return nil
    }

    func saveMessage(message:String, fromId: Int, toId: Int, date: Date = Date()) {
        let managedContext = self.persistentContainer.viewContext
        let e = MessageEntity(context: managedContext)
        e.sendDate = date
        e.fromId = Int64(fromId)
        e.toId = Int64(toId)
        e.text = message

        let user1 = user(forId: fromId)
        user1?.lastMessageDate = date
        user1?.lastMessagePrev = message

        self.saveContext()
    }

    func getMessages(forUserId id: Int, partnerId: Int, afterDate date: Date? = nil) -> [MessageEntity] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let pred1 = NSPredicate(format: "fromId == \(id) && toId == \(partnerId)")
        let pred2 = NSPredicate(format: "fromId == \(partnerId) && toId == \(id)")
        let compoundPred = NSCompoundPredicate.init(orPredicateWithSubpredicates: [pred1, pred2])
        let sort = NSSortDescriptor(key: "sendDate", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = compoundPred
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.persistentContainer.viewContext.fetch(request)
            return result as? [MessageEntity] ?? []
        } catch {
            print("Failed")
        }
        return []
    }

    ///Deletes all users in database
    func deleteAllUsers() {
        let context = self.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }

    ///Deletes all messages in database
    func deleteAllMessages() {
        let context = self.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }

    ///Return all followers sorted by id
    func getFollowers(_ userHandle:String? = nil) -> [UserEntity] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let sort1 = NSSortDescriptor(key: "login", ascending: true)
        let sort2 = NSSortDescriptor(key: "lastMessageDate", ascending: false)
        if let userHandle = userHandle {
            let pred = NSPredicate(format: "login !=[c] %@", userHandle)
            request.predicate = pred
        }
        request.sortDescriptors = [sort2, sort1]
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.persistentContainer.viewContext.fetch(request)
            return result as? [UserEntity] ?? []
        } catch {
            print("Failed")
        }
        return []
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "GDM")
        container.loadPersistentStores(completionHandler: { (_, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
