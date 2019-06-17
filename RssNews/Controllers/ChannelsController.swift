//
//  ChannelsController.swift
//  RssNews
//
//  Created by Игорь Пинаев on 29/05/2019.
//  Copyright © 2019 Igor Pinaev. All rights reserved.
//

import UIKit

class ChannelsController: UIViewController {

    @IBOutlet private weak var channelsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelsTable.delegate = self
        channelsTable.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        channelsTable.reloadData()
    }
    @IBAction func pushAddChannel(_ sender: Any) {
        addChannel(channelName: "", channelLink: "", index: nil)
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
        var btnTitle: String
        if index == nil {
            title = "Add new channel"
            btnTitle = "Add"
        } else {
            title = "Update channel"
            btnTitle = "Update"
        }
        
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
        
        let alertActionAdd = UIAlertAction(title: btnTitle, style: .default) { (alert) in
            let name = alertController.textFields?[0].text
            let link = alertController.textFields?[1].text
            
            if name != "" && link != "" {
                if Model.sharedInstance.validateUrl(url: link!) {
                    if index != nil{
                        channels[index!].setValuesForKeys(["name" : name! , "link" : link!])
                    } else {
                    _ = Channel.newChannel(name: name!, link: link!)
                    }
                    CoreDataManager.sharedInstance.saveContext()
                    self.channelsTable.reloadData()
                } else { self.showAlert(error: "Введите корректный адрес источника", channelName: name!, channelLink: link!, index: index)}
            } else {self.showAlert(error: "Пожалуйста заполните все поля", channelName: name!, channelLink: link!, index: index)}
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(alertActionCancel)
        alertController.addAction(alertActionAdd)
        present(alertController, animated: true, completion: nil)
    }
}

extension ChannelsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath)
        
        let channelInCell = channels[indexPath.row]
        
        cell.textLabel?.text = channelInCell.name
        cell.detailTextLabel?.text = channelInCell.link
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNews", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNews" {
            guard let destination = segue.destination as? NewsController else {return}
            if let indexpath = channelsTable.indexPathForSelectedRow {
                destination.channel = channels[indexpath.row]
            }
        }
    }
    
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
                let channelInCell = channels[indexPath.row]
                CoreDataManager.sharedInstance.managedObjectContext.delete(channelInCell)
                CoreDataManager.sharedInstance.saveContext()
                completion(true)
                
            }
            delete.backgroundColor = UIColor.red
            delete.image = UIImage(named: "bin")
            return UISwipeActionsConfiguration(actions: [delete])
        }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: nil) { (action, view, nil) in
            let channelInCell = channels[indexPath.row]
            self.addChannel(channelName: channelInCell.name!, channelLink: channelInCell.link!, index: indexPath.row)
        }
        edit.backgroundColor = UIColor.orange
        edit.image = UIImage(named: "edit")
        
        return UISwipeActionsConfiguration(actions: [edit])
    }
}
