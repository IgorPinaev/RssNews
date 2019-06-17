//
//  ArticleCollectionCell.swift
//  RssNews
//
//  Created by Игорь Пинаев on 17/06/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit

class ArticleCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageArticle: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var labelContent: UILabel!
    
    func initCell(title: String?, content: String?, date: String?, image: NSData?) {
        imageArticle.image = (image == nil) ? nil : UIImage(data: image! as Data)
        labelTitle.text = title
        labelDate.text = date
        labelContent.text = content
    }
    
}
