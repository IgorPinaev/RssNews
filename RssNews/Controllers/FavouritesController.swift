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

    @IBOutlet private weak var favouritesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favouritesTable.delegate = self
        favouritesTable.dataSource = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(NewsController.longPressGestureRecognized(_:)))
        favouritesTable.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favouritesTable.reloadData()
    }
    
    func share(index: Int) {
        let alert = UIAlertController(title: "Title", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove from favourites", style: .destructive, handler: { (action) in
            let article = favourites[index]
            CoreDataManager.sharedInstance.managedObjectContext.delete(article)
            CoreDataManager.sharedInstance.saveContext()
            self.favouritesTable.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension FavouritesController: UITableViewDelegate, UITableViewDataSource {
    
    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer.location(in: favouritesTable)
        let indexPath = favouritesTable.indexPathForRow(at: longPress)
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if let index = indexPath?.row {
                share(index: index)
            }
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! ArticleCell
        let articleInCell = favourites[indexPath.row]
        
        cell.initCell(title: articleInCell.title, content: articleInCell.content, date: articleInCell.pubDate?.toString(), image: articleInCell.image)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let articleInCell = favourites[indexPath.row]
        
        if let url = URL(string: articleInCell.link!) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
}
