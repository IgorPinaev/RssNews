//
//  Channel+CoreDataClass.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Channel)
public class Channel: NSManagedObject {

    class func newChannel(name: String, link:String) -> Channel{
        let channel = Channel(context: CoreDataManager.sharedInstance.managedObjectContext)
        channel.name = name
        channel.link = link
        
        return channel
    }
    
    var articlesSorted: [Article] {
        let sortDescriptor = NSSortDescriptor(key: "pubDate", ascending: false)
        return self.article?.sortedArray(using: [sortDescriptor]) as! [Article]
    }
}
