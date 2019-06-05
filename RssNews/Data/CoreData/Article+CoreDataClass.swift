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
        article.content = content
        article.pubDate = article.stringToDate(stringDate: pubDate)
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
    
    private func stringToDate(stringDate: String) -> NSDate {
        let dateFormatter = DateFormatter()
        //        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        guard let date = dateFormatter.date(from: stringDate) else {return NSDate()}
        return date as NSDate
    }
    
    func dateToString(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        dateFormatter.dateFormat = "HH:mm  d MMM yyyy"
        return dateFormatter.string(from: date as Date)
    }
}
