//
//  Model.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import Foundation
import UIKit

class Model: NSObject {
    static let sharedInstance = Model()

    private var isLoading: Bool = false
    
    private var channelForArticle: Channel?
    
    func loadData(channel: Channel, completionHandler: (()-> Void)?) {
        if isLoading {return}
        guard let stringURL =  channel.link else {return}
        channelForArticle = channel
        
        let url = URL(string: stringURL)
        let session = URLSession(configuration: .default)
        isLoading = true
        let dataTask = session.dataTask(with: url!) { (data, responce, error) in
            guard let data = data else {
                if let error = error {
                    self.isLoading = false
                    print(error.localizedDescription)
                    if error.localizedDescription == "The Internet connection appears to be offline."
                    {return}
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "error"), object: self)
                }
                return
            }
            self.clearArticles(channel: self.channelForArticle!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataClear"), object: self)
            
            let feedParser = FeedParser()
            feedParser.channelForArticle = self.channelForArticle
            feedParser.parseXML(data: data)
            self.loadImage(urlsToImages: feedParser.urlsToImages)
            self.isLoading = false
            completionHandler?()
        }
        dataTask.resume()
    }

    func clearArticles(channel: Channel) {
        if channel.articlesSorted.count != 0 {
            DispatchQueue.main.async {
                for article in channel.articlesSorted {
                    CoreDataManager.sharedInstance.managedObjectContext.delete(article)
                }
                CoreDataManager.sharedInstance.saveContext()
            }
        }
    }
    
//    func parseJSON(data: Data) {
//        let rootDictionaryAny = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
//        guard let rootDictionary = rootDictionaryAny as? Dictionary<String, Any> else {return}
//
//        if let array = rootDictionary["articles"] as? [Dictionary<String, Any>] {
//            for dict in array {
//                _ = Article.newJsonArticle(dictionary: dict)
//            }
//            CoreDataManager.sharedInstance.saveContext()
//        }
//    }

    

    var images: [NSData?] = []

    func loadImage(urlsToImages: [String]) {
        for url in urlsToImages {
            if let url = URL(string: url) {
                if let data = try? Data(contentsOf: url){
                    images.append(UIImage(data: data)?.jpegData(compressionQuality: 0.2) as NSData?)
                }
            } else {
                images.append(nil)
            }
        }
        DispatchQueue.main.async {
            guard let count = self.channelForArticle?.articlesSorted.count else {return}
            for index in 0 ... count - 1 {
                self.channelForArticle?.articlesSorted[index].image = self.images[index]
            }
            CoreDataManager.sharedInstance.saveContext()
            self.images = []
        }
    }
    
    func validateUrl(url: String) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*)+)+(/)?(\\?.*)?"
        let predicate = NSPredicate(format:"SELF MATCHES %@",
                                    argumentArray:[urlRegEx])
        _ = NSPredicate.withSubstitutionVariables(predicate)
        return predicate.evaluate(with: url)
    }
}
