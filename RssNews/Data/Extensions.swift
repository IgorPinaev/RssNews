//
//  Extensions.swift
//  RssNews
//
//  Created by Игорь Пинаев on 06/06/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import Foundation

extension NSDate {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        dateFormatter.dateFormat = "HH:mm  d MMM yyyy"
        return dateFormatter.string(from: self as Date)
    }
}

extension String {
    func toDate() -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        guard let date = dateFormatter.date(from: self) else {return NSDate()}
        return date as NSDate
    }
    
    var htmlToString: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        
        guard let attibutedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return self}
        return attibutedString.string
    }
}
