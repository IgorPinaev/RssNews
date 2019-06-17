//
//  FavouritesController.swift
//  RssNews
//
//  Created by Игорь Пинаев on 07/06/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit
import SafariServices

class FavouritesController: UIViewController {

    @IBOutlet weak var favouritesCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favouritesCollection.delegate = self
        favouritesCollection.dataSource = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(NewsController.longPressGestureRecognized(_:)))
        favouritesCollection.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favouritesCollection.reloadData()
    }
    
    func share(index: Int) {
        let alert = UIAlertController(title: "Title", message: nil, preferredStyle: .actionSheet)
        let article = favourites[index]
        
        alert.addAction(UIAlertAction(title: "Remove from favourites", style: .destructive, handler: { (action) in
            CoreDataManager.sharedInstance.managedObjectContext.delete(article)
            CoreDataManager.sharedInstance.saveContext()
            self.favouritesCollection.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { (action) in
                self.openInSafari(urlString: article.link)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func openInSafari(urlString: String?) {
        if let url = URL(string: urlString!) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
}

extension FavouritesController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsItem", for: indexPath) as! ArticleCollectionCell
        let articleInCell = favourites[indexPath.row]
        
        cell.initCell(title: articleInCell.title, content: articleInCell.content, date: articleInCell.pubDate?.toString(), image: articleInCell.image)
        
        return cell
    }
    
    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer.location(in: favouritesCollection)
        let indexPath = favouritesCollection.indexPathForItem(at: longPress)
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if let index = indexPath?.row {
                share(index: index)
            }
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articleInCell = favourites[indexPath.row]
        openInSafari(urlString: articleInCell.link)
    }
}
