//
//  ArticleCell.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var imageArticle: UIImageView!
    
    func initCell(title: String?, content: String?, date: String?, image: NSData?) {
        
        imageArticle.image = (image == nil) ? nil : UIImage(data: image! as Data)
        labelTitle.text = title
        labelDate.text = date
        labelDescription.text = content
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
