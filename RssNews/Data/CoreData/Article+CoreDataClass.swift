//
//  Article+CoreDataClass.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Article)
public class Article: NSManagedObject {

    class func newXmlArticle(title: String, link: String, content: String, pubDate: String, image: NSData?, channel: Channel?) -> Article {
        let article = Article(context: CoreDataManager.sharedInstance.managedObjectContext)
        article.title = title
        article.link = link
        article.content = content.htmlToString
        article.pubDate = pubDate.toDate()
        article.image = image
        if let channel = channel {
            article.channel = channel
        }
        return article
    }
    
//    class func newJsonArticle(dictionary: Dictionary<String, Any>) -> Article{
//        let article = Article(context: CoreDataManager.sharedInstance.managedObjectContext)
//        article.title = dictionary["title"] as? String ?? ""
//        article.link = dictionary["url"] as? String ?? ""
//        article.content = dictionary["description"] as? String ?? ""
//        article.pubDate = dictionary["publishedAt"] as? String ?? ""
//        article.convertUrlToImage(urlString: dictionary["urlToImage"] as? String ?? "")
//
//        return article
//    }
}
