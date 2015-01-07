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
    @NSManaged var body: String
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

    func update(key: String, createdate: NSTimeInterval, modifydate: NSTimeInterval,
                version: Int32) {
        var note: Note

        // EntityDescriptionのインスタンスを生成
        let req = NSFetchRequest(entityName: "Note")
        req.returnsObjectsAsFaults = false
        req.predicate = NSPredicate(format: "%K = %@", "key", key)

        // フェッチリクエストの実行
        println("Search \(key) in DB...")
        let results = context.executeFetchRequest(req, error: nil)
        if let notes = results as? [Note] {
            if notes.count > 0 {
                println("Found")
                note = notes[0]
            }else{
                println("Not found, create new entity")
                note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as Note
                note.key = key
            }
            note.createdate = createdate
            note.modifydate = modifydate
            note.version = version
            context.save(nil)
        }else{
            println("executeFetchRequest() failed")
        }
    }

    func update_body(key: String, body: String) {
        var note: Note

        // EntityDescriptionのインスタンスを生成
        let req = NSFetchRequest(entityName: "Note")
        req.returnsObjectsAsFaults = false
        req.predicate = NSPredicate(format: "%K = %@", "key", key)

        // フェッチリクエストの実行
        println("Search \(key) in DB...")
        let results = context.executeFetchRequest(req, error: nil)
        if let notes = results as? [Note] {
            if notes.count > 0 {
                notes[0].body = body
                context.save(nil)
            }
        }
    }
}
