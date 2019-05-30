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
    
    func loadData(stringURL: String, completionHandler: (()-> Void)?) {
        
        let url = URL(string: stringURL)
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url!) { (data, responce, error) in
            guard let data = data else {
                if let error = error {
                    print("!!!!!!!!!!!!" + error.localizedDescription)
                }
                return
            }
            self.parseXML(data: data)
            completionHandler?()
        }
        dataTask.resume()
    }

    func parseJSON(data: Data) {
        let rootDictionaryAny = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let rootDictionary = rootDictionaryAny as? Dictionary<String, Any> else {return}
        
        if let array = rootDictionary["articles"] as? [Dictionary<String, Any>] {
            for dict in array {
                _ = Article.newJsonArticle(dictionary: dict)
            }
            CoreDataManager.sharedInstance.saveContext()
        }
    }

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
            _ = Article.newXmlArticle(title: self.currentTitle, link: self.currentLink, content: self.currentContent, pubDate: self.currentPubDate, urlToImage: currentUrlToImage)
                CoreDataManager.sharedInstance.saveContext()
//            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
