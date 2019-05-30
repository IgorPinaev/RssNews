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
        
        let alertController = UIAlertController(title: "Add new channel", message: nil
            , preferredStyle: .alert)
        
        alertController.addTextField { (text) in
            text.placeholder = "Channel title"
        }
        alertController.addTextField { (text) in
            text.placeholder = "Channel link"
        }
        
        let alertActionAdd = UIAlertAction(title: "Add", style: .default) { (alert) in
            let channelName = alertController.textFields?[0].text
            let channelLink = alertController.textFields?[1].text
//            let channelLink = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=009bf23be7fa455095ae15b261ac5e0a"
            if channelName != "" && channelLink != "" {
                _ = Channel.newChannel(name: channelName!, link: channelLink!)
                CoreDataManager.sharedInstance.saveContext()
                self.tableView.reloadData()
            }
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(alertActionCancel)
        alertController.addAction(alertActionAdd)
        present(alertController, animated: true, completion: nil)
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
                destination.link = channels[indexpath.row].link
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

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let channelInCell = channels[indexPath.row]
            
            CoreDataManager.sharedInstance.managedObjectContext.delete(channelInCell)
            CoreDataManager.sharedInstance.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
