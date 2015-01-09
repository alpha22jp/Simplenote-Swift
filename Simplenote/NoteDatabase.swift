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
}

class NoteDatabase {
    var context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchRequest() -> NSFetchRequest {
        let req = NSFetchRequest(entityName: "Note")
        let sort = NSSortDescriptor(key: "modifydate", ascending: true)
        req.sortDescriptors = [sort]
        return req
    }

    func createEntity(key: String) -> Note {
        var note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as Note
        note.key = key
        return note
    }

    func searchEntity(key: String) -> Note? {
        // EntityDescriptionのインスタンスを生成
        let req = NSFetchRequest(entityName: "Note")
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
        entity.content = content
        context.save(nil)
    }
}
