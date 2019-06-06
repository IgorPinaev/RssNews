//
//  ArticleCell.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var imageArticle: UIImageView!
    
    private var article: Article?
    
    func initCell(article: Article) {
        self.article = article
        
        // heightConstraint.constant = 0 if nil
        if article.image != nil {
            imageArticle.image = UIImage(data: article.image! as Data)
        } else {imageArticle.image = nil}
        labelTitle.text = article.title
        labelDate.text = article.pubDate?.toString()
        labelDescription.text = article.content
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
