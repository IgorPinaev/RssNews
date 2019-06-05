//
//  XmlParser.swift
//  RssNews
//
//  Created by Игорь Пинаев on 05/06/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit

class FeedParser: NSObject, XMLParserDelegate {

    struct ArticleStuct {
        var title: String
        var link: String
        var content: String
        var pubDate: String
    }
    
    private var articlesDownload: [ArticleStuct] = []
    var urlsToImages: [String] = []
    var channelForArticle: Channel?
    
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
            let article = ArticleStuct(title: currentTitle, link: currentLink, content: currentContent, pubDate: currentPubDate)
            articlesDownload.append(article)
            urlsToImages.append(currentUrlToImage)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            for article in self.articlesDownload {
                _ = Article.newXmlArticle(title: article.title, link: article.link, content: article.content, pubDate: article.pubDate, image: nil, channel: self.channelForArticle)
            }
            CoreDataManager.sharedInstance.saveContext()
            Model.sharedInstance.urlsToImages = self.urlsToImages
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//        isLoading = false
        print(parseError.localizedDescription)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "error"), object: self)
    }
}
