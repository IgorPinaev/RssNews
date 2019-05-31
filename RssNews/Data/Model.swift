//
//  Model.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import Foundation

class Model: NSObject, XMLParserDelegate {
    static let sharedInstance = Model()

    private var currentElement: String = ""
    private var currentTitle: String = "" {
        didSet{
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentLink: String = "" {
        didSet{
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentContent: String = "" {
        didSet{
            currentContent = currentContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String = "" {
        didSet{
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentUrlToImage: String = ""
    private var channelForArticle: Channel?
    
    
    func loadData(channel: Channel, completionHandler: (()-> Void)?) {
        guard let stringURL =  channel.link else {return}
        channelForArticle = channel
        
        let url = URL(string: stringURL)
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url!) { (data, responce, error) in
            guard let data = data else {
                if let error = error {
                    print("!!!!!!!!!!!!" + error.localizedDescription)
                }
                return
            }
            self.clearArticles(channel: self.channelForArticle!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataClear"), object: self)
            
            self.parseXML(data: data)
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

    func parseXML(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentContent = ""
            currentPubDate = ""
            currentLink = ""
            currentUrlToImage = ""
        }
        
        if currentElement == "enclosure" {
            if let url = attributeDict["url"] {
                currentUrlToImage = url
            } else {
                currentUrlToImage = ""
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String){
        
        switch currentElement {
        case "title": currentTitle = string
        case "link": currentLink = string
        case "description": currentContent = string
        case "pubDate": currentPubDate = string
        default:
            break
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
//            DispatchQueue.main.async {
            _ = Article.newXmlArticle(title: currentTitle, link: currentLink, content: currentContent, pubDate: currentPubDate, urlToImage: currentUrlToImage, channel: channelForArticle)
                CoreDataManager.sharedInstance.saveContext()
//            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
