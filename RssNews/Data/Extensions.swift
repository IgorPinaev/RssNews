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
//        dateFormatter.locale = Locale.init(identifier: "en_US".localize())
        dateFormatter.dateFormat = "HH:mm  d MMM yyyy"
        return dateFormatter.string(from: self as Date)
    }
}

extension String {
    func toDate() -> NSDate {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let date = dateFormatter.date(from: self)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter2.dateFormat = "E, d MMM yyyy HH:mm:ss z"
        let date2 = dateFormatter2.date(from: self)
        
        guard let dateUnwrapped = date else {return date2! as NSDate}
        return dateUnwrapped as NSDate
    }
    
    var htmlToString: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        
        guard let attibutedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return self}
        return attibutedString.string
    }
    
    func localize() -> String{
        return NSLocalizedString(self, comment: "")
    }
}
