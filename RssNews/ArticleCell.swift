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
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var imageArticle: UIImageView!
    
    var article: Article?
    
    func initCell(article: Article) {
        self.article = article
        
        if article.image != nil {
            imageArticle.image = UIImage(data: article.image! as Data)
        } 
        labelTitle.text = article.title
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
