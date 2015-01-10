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

    func getFetchedResultController(sort: NSSortDescriptor, predicate: NSPredicate!) -> NSFetchedResultsController {
        let req = getFetchRequest()
        req.sortDescriptors = [sort]
        req.predicate = predicate
        return NSFetchedResultsController(fetchRequest: req, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }

    func createEntity(key: String) -> Note {
        var note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as Note
        note.key = key
        return note
    }

    func searchEntity(key: String) -> Note? {
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

    func updateEntity(entity: Note, note: Simplenote.Note, content: String) {
        entity.createdate = note.createdate
        entity.modifydate = note.modifydate
        entity.version = note.version
        entity.isdeleted = (note.deleted == 1)
        entity.content = content
        context.save(nil)
    }
}
