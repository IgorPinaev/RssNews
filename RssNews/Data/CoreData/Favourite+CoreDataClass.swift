//
//  Favourite+CoreDataClass.swift
//  RssNews
//
//  Created by Игорь Пинаев on 06/06/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Favourite)
public class Favourite: NSManagedObject {

    class func addToFavourite(title: String?, link: String?, content: String?, pubDate: NSDate?, image: NSData?) -> Favourite {
        let article = Favourite(context: CoreDataManager.sharedInstance.managedObjectContext)
        article.title = title
        article.link = link
        article.content = content
        article.pubDate = pubDate
        article.image = image

        return article
    }
    
}
