//
//  NoteDatabase.swift
//  Simplenote Note database supported by CoreData
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import CoreData

class Note: NSManagedObject {
    @NSManaged var key: String
    @NSManaged var content: String
    @NSManaged var createdate: NSTimeInterval
    @NSManaged var modifydate: NSTimeInterval
    @NSManaged var version: Int32
    @NSManaged var isdeleted: Bool
}

class NoteDatabase {
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    private func getFetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: "Note")
    }

    func getFetchedResultsController(sort: NSSortDescriptor, predicate: NSPredicate!, delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController {
        let req = getFetchRequest()
        req.sortDescriptors = [sort]
        req.predicate = predicate
        let controller = NSFetchedResultsController(fetchRequest: req, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = delegate
        return controller
    }

    func createNote(key: String) -> Note {
        var note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as Note
        note.key = key
        return note
    }

    func searchNote(key: String) -> Note? {
        // EntityDescriptionのインスタンスを生成
        let req = getFetchRequest()
        req.returnsObjectsAsFaults = false
        req.predicate = NSPredicate(format: "%K = %@", "key", key)

        // フェッチリクエストの実行
        let results = context.executeFetchRequest(req, error: nil)
        if let notes = results as? [Note] {
            if notes.count > 0 {
                return notes[0]
            }
        }
        return nil
    }

    func update() {
        context.save(nil)
    }
}
