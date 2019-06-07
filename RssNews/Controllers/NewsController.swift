//
//  NewsController.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit
import SafariServices

class NewsController: UITableViewController {

    var channel: Channel?
    let indicator = UIActivityIndicatorView(style: .gray)

    
    private var articlesInChannel: [Article] {
        if let channel = channel {
            return channel.articlesSorted
        }
        return articles
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = channel?.name
        
        indicator.hidesWhenStopped = true
        indicator.center = self.view.center
        indicator.color = UIColor.orange
        view.addSubview(indicator)
        indicator.startAnimating()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "endRefreshing"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.indicator.stopAnimating()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "dataClear"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
              self.tableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "error"), object: nil, queue: nil) { (notification) in
            self.showError()
        }
        
        Model.sharedInstance.loadData(channel: channel!) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.indicator.stopAnimating()
            }
        }
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(NewsController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: longPress)
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if let index = indexPath?.row {
                share(index: index)
            }
            return
        }
    }
    
    @IBAction func refreshControlAction(_ sender: Any) {
        Model.sharedInstance.loadData(channel: channel!) {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesInChannel.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! ArticleCell
        let articleInCell = articlesInChannel[indexPath.row]
        
        cell.initCell(title: articleInCell.title, content: articleInCell.content, date: articleInCell.pubDate?.toString(), image: articleInCell.image)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let articleInCell = articlesInChannel[indexPath.row]
        
        if let url = URL(string: articleInCell.link!) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }

    func showError() {
        let alertController = UIAlertController(title: "Ошибка при загрузке", message: "Проверьте ссылку источника", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(actionOK)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func share(index: Int) {
        let alert = UIAlertController(title: "Title", message: nil, preferredStyle: .actionSheet)
        
        let article = self.articlesInChannel[index]
        if favourites.firstIndex(where: {$0.title == article.title && $0.link == article.link && $0.content == article.content && $0.pubDate == article.pubDate && $0.image == article.image}) == nil {
        alert.addAction(UIAlertAction(title: "Add to favourites", style: .default, handler: { (action) in
            _ = Favourite.addToFavourite(title: article.title, link: article.link, content: article.content, pubDate: article.pubDate, image: article.image)
            CoreDataManager.sharedInstance.saveContext()
        }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
