//
//  Favourite+CoreDataProperties.swift
//  RssNews
//
//  Created by Игорь Пинаев on 06/06/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//
//

import Foundation
import CoreData


extension Favourite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourite> {
        return NSFetchRequest<Favourite>(entityName: "Favourite")
    }

    @NSManaged public var title: String?
    @NSManaged public var link: String?
    @NSManaged public var content: String?
    @NSManaged public var pubDate: NSDate?
    @NSManaged public var image: NSData?

}
