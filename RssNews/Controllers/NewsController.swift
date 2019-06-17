//
//  NewsController.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit
import SafariServices

class NewsController: UIViewController {

    var channel: Channel?
    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var newsCollection: UICollectionView!
    
    private var articlesInChannel: [Article] {
        if let channel = channel {
            return channel.articlesSorted
        }
        return articles
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsCollection.delegate = self
        newsCollection.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        newsCollection.refreshControl = refreshControl
        
        navigationItem.title = channel?.name
        newsCollection.refreshControl?.beginRefreshing()
        refreshControlAction(self)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "endRefreshing"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.newsCollection.refreshControl?.endRefreshing()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "dataClear"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
              self.newsCollection.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "error"), object: nil, queue: nil) { (notification) in
            self.showError()
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(NewsController.longPressGestureRecognized(_:)))
        newsCollection.addGestureRecognizer(longPress)
    }
    
    @objc func refreshControlAction(_ sender: Any) {
        Model.sharedInstance.loadData(channel: channel!) {
            DispatchQueue.main.async {
                self.newsCollection.refreshControl?.endRefreshing()
                self.newsCollection.reloadData()
            }
        }
    }
    
    func showError() {
        let alertController = UIAlertController(title: "Loading error", message: "Check source link", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(actionOK)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func share(index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let article = self.articlesInChannel[index]
        if favourites.firstIndex(where: {$0.title == article.title && $0.link == article.link && $0.content == article.content && $0.pubDate == article.pubDate && $0.image == article.image}) == nil {
        alert.addAction(UIAlertAction(title: "Add to favourites", style: .default, handler: { (action) in
            _ = Favourite.addToFavourite(title: article.title, link: article.link, content: article.content, pubDate: article.pubDate, image: article.image)
            CoreDataManager.sharedInstance.saveContext()
        }))
        }
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

extension NewsController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articlesInChannel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsItem", for: indexPath) as! ArticleCollectionCell
        let articleInCell = articlesInChannel[indexPath.row]
        
        cell.initCell(title: articleInCell.title, content: articleInCell.content, date: articleInCell.pubDate?.toString(), image: articleInCell.image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articleInCell = articlesInChannel[indexPath.row]
        openInSafari(urlString: articleInCell.link)
    }
    
    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer.location(in: newsCollection)
        let indexPath = newsCollection.indexPathForItem(at: longPress)
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if let index = indexPath?.row {
                share(index: index)
            }
            return
        }
    }
}

extension NewsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height / 3
        return CGSize(width: width, height: height)
    }
}
