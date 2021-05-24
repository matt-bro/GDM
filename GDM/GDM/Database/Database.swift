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
}

class Database: DatabaseReadable, DatabaseSavable {

    static let shared = Database()

    ///Initially fills our database with a local json if needed
    func inititalSetup() {
//        let  jsonPath = Bundle.main.path(forResource: "initial-data", ofType: "json")
//
//        guard self.getQuotes().isEmpty else {
//            return
//        }
//
//        do {
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .secondsSince1970
//            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath!), options: .mappedIfSafe)
//            let jsonResult = try decoder.decode(CurrencyResponse.self, from: data)
//            UserDefaults.standard.lastMetaDataDate = Date()
//            UserDefaults.standard.quoteDataDate = jsonResult.timestamp
//            self.saveQuotes(quotes: jsonResult.quotes)
//        } catch {
//            fatalError("could not setup database")
//        }
    }

    ///Save our users
    func saveQuotes(quotes: [String: Double]) {
//        //I don't want to check for update/insert so I delete all entries before
//        self.deleteAllQuotes()
//
//        let managedContext = self.persistentContainer.viewContext
//        for quote in quotes {
//            let e = Currency(context: managedContext)
//            e.id = quote.key
//            e.code = quote.key
//
//            //the quote key seems to be in format e.g. USDUSD, USDEUR
//            //I assume I can cut the first 3 characters to get the clean currency code
//            if quote.key.count >= 6 {
//                e.country = quote.key[3...5]
//            } else {
//                e.country = quote.key
//            }
//
//            e.value = quote.value
//            e.sign = getSymbol(forCurrencyCode: e.country ?? "") ?? ""
//            e.image = getCountryImage(forCurrencyCode: e.country)?.pngData()
//        }
//        self.saveContext()
    }

    func saveUsers(_ userResponses: [UserResponse]) {
        //I don't want to check for update/insert so I delete all entries before
        self.deleteAllUsers()

        let managedContext = self.persistentContainer.viewContext
        for ur in userResponses {
            let e = UserEntity(context: managedContext)
            e.id = Int64(ur.id)
            e.nodeId = ur.node_id
            e.login = ur.login
            e.avatarUrl = ur.avatar_url
        }
        self.saveContext()
    }

    ///Deletes all quotes in database
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

    ///Return all quotes sorted by country
    func getFollowers(_ userHandle:String? = nil) -> [UserEntity] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
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
