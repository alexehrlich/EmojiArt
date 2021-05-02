//
//  EmojiArtDocumentTableViewController.swift
//  EmojiArt
//
//  Created by Alexander Ehrlich on 01.05.21.
//

import UIKit

class EmojiArtDocumentTableViewController: UITableViewController {

    var emojiArtDocs = ["One", "Two"]

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return emojiArtDocs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        cell.textLabel?.text = emojiArtDocs[indexPath.row]
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    @IBAction func addDocument(_ sender: UIBarButtonItem) {
        
        emojiArtDocs += ["Untiteld".madeUnique(withRespectTo: emojiArtDocs)]
        tableView.reloadData()
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            emojiArtDocs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    //Im Master muss der content-Mode eingestellt werden. Soll der Master eingeklappt werden oder immer da sein?
    override func viewWillLayoutSubviews() {
        //In dieser Methode wird der Master contentmode oft zurückgestezt
        super.viewWillLayoutSubviews()
        //Achtung, dass keine Endlosschrliefe erzeugt wird, denn das setzen des content-mode ruft layoutSubwies wieder auf:
        if splitViewController?.preferredDisplayMode != .oneOverSecondary {
            splitViewController?.preferredDisplayMode =  .oneOverSecondary
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
