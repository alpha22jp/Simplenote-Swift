//
//  NoteDatabase.swift
//  Simplenote Note database supported by CoreData
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import CoreData

// MARK: - ノート情報のクラス (CoreDataのNote Entityに紐付けられている)
class Note: NSManagedObject {
    @NSManaged var key: String
    @NSManaged var content: String
    @NSManaged var createdate: NSTimeInterval
    @NSManaged var modifydate: NSTimeInterval
    @NSManaged var version: Int32
    @NSManaged var isdeleted: Bool
    @NSManaged var markdown: Bool
}

// MARK: - ノート情報のデータベースを管理するクラス
final class NoteDatabase {

    class var sharedInstance: NoteDatabase {
        struct Static {
            static let instance = NoteDatabase()
        }
        return Static.instance
    }
    private init(){}

    // MARK: - Core Data stack (Migrated from AppDelegate.swift)

    private lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.alpha22jp.Simplenote" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Simplenote", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Simplenote.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    private lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support (Migrated from AppDelegate.swift)

    func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

    // MARK: - Note Database operation

    // MARK: Note Entityに対するNSFetchRequestを返す
    private func getFetchRequest() -> NSFetchRequest {
        let req = NSFetchRequest(entityName: "Note")
        req.returnsObjectsAsFaults = false
        return req
    }

    // MARK: 与えられたNSFetchRequestで検索して結果をNoteの配列で返す
    private func executeFetch(req: NSFetchRequest) -> [Note] {
        let results = managedObjectContext?.executeFetchRequest(req, error: nil)
        let notes = results as? [Note]
        return (notes ?? [])
    }

    // MARK: 与えられた条件に対応するNSFetchedResultsControllerを返す
    func getFetchedResultsController(sort: NSSortDescriptor, predicate: NSPredicate!, delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController {
        let req = getFetchRequest()
        req.sortDescriptors = [sort]
        req.predicate = predicate
        let controller = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = delegate
        return controller
    }

    // MARK: ノートを新規作成して作成したノートを返す
    func createNote(key: String) -> Note {
        var note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: managedObjectContext!) as Note
        note.key = key
        return note
    }

    // MARK: 与えられたキーに一致するノートを返す
    func searchNote(key: String) -> Note? {
        let req = getFetchRequest()
        req.predicate = NSPredicate(format: "%K = %@", "key", key)
        let notes = executeFetch(req)
        return notes.count > 0 ? notes[0] : nil
    }

    // MARK: 指定されたノートを削除する
    func deleteNote(note: Note) {
        managedObjectContext?.deleteObject(note)
        saveContext()
    }

    // MARK: キーが一致するノートを削除する
    func deleteNoteByKey(key: String) {
        let note = searchNote(key)
        if let _note = note {
            deleteNote(_note)
        }
    }

    // MARK: すべてのノートを削除する
    func deleteAllNotes() {
        let notes = executeFetch(getFetchRequest())
        for note in notes {
            managedObjectContext?.deleteObject(note)
        }
        saveContext()
    }

    // MARK: データベースが空かどうかを返す
    func isEmpty() -> Bool {
        let notes = executeFetch(getFetchRequest())
        return (notes.count == 0)
    }
}
