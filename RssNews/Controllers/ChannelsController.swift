//
//  ChannelsController.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit

class ChannelsController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pushAddChannel(_ sender: Any) {
        addChannel(channelName: "", channelLink: "", index: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath)

        let channelInCell = channels[indexPath.row]
        
        cell.textLabel?.text = channelInCell.name
        cell.detailTextLabel?.text = channelInCell.link

        return cell
    }
 
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNews", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNews" {
            guard let destination = segue.destination as? NewsController else {return}
            if let indexpath = tableView.indexPathForSelectedRow {
                destination.channel = channels[indexpath.row]
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let update = updateAction(at: indexPath)
//        let delete = deleteAction(at: indexPath)
//        return UISwipeActionsConfiguration(actions: [delete, update)
//    }
//
//    func updateAction(at: indexPath) -> UIContextualAction {
//
//    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { (action, view, nil) in
            let channelInCell = channels[indexPath.row]
            self.addChannel(channelName: channelInCell.name!, channelLink: channelInCell.link!, index: indexPath.row)
        }
        action.backgroundColor = UIColor.orange
        action.image = UIImage(named: "edit")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let channelInCell = channels[indexPath.row]
            
            CoreDataManager.sharedInstance.managedObjectContext.delete(channelInCell)
            CoreDataManager.sharedInstance.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }    
    }
 
    
    func showAlert(error: String, channelName: String, channelLink: String, index: Int?) {
        let alertError = UIAlertController(title: "Ошибка", message: error, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.addChannel(channelName: channelName, channelLink: channelLink, index: index)
        }
        alertError.addAction(actionOk)
        present(alertError, animated: true, completion: nil)
    }
    
    func addChannel(channelName: String, channelLink: String, index: Int?){
        var title: String
        if index == nil {
            title = "Add new channel"
        } else { title = "Update channel"}
        
        let alertController = UIAlertController(title: title, message: nil
            , preferredStyle: .alert)
        
        alertController.addTextField { (text) in
            text.text = channelName
            text.placeholder = "Channel title"
        }
        alertController.addTextField { (text) in
            text.text = channelLink
            text.placeholder = "Channel link"
        }
        
        let alertActionAdd = UIAlertAction(title: "Add", style: .default) { (alert) in
            let name = alertController.textFields?[0].text
            let link = alertController.textFields?[1].text
            
            if name != "" && link != "" {
                if Model.sharedInstance.validateUrl(url: link!) {
                    if index != nil{
                        let channelInCell = channels[index!]
                        CoreDataManager.sharedInstance.managedObjectContext.delete(channelInCell)
                    }
                    _ = Channel.newChannel(name: name!, link: link!)
                    CoreDataManager.sharedInstance.saveContext()
                    self.tableView.reloadData()
                } else { self.showAlert(error: "Введите корректный адрес источника", channelName: name!, channelLink: link!, index: index)}
            } else {self.showAlert(error: "Пожалуйста заполните все поля", channelName: name!, channelLink: link!, index: index)}
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(alertActionCancel)
        alertController.addAction(alertActionAdd)
        present(alertController, animated: true, completion: nil)
    }

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

   

}
