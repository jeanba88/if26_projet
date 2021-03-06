//
//  TrajetsTableViewController.swift
//  if26_projet
//
//  Created by Jean-baptiste Blot on 16/12/2017.
//  Copyright © 2017 Jean-baptiste Blot. All rights reserved.
//

import UIKit

class TrajetTableViewCell: UITableViewCell {
    @IBOutlet weak var labelGareDepart: UILabel!
    @IBOutlet weak var labelGareArrive: UILabel!
}

class TrajetsTableViewController: UITableViewController {
    let db:Database = Database()
    var trajets:[Trajet] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        trajets.removeAll()
        trajets += db.selectTrajet()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trajets.count
    }

    @IBAction func ReloadButtonClicked(_ sender: Any) {
        reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trajetCell", for: indexPath) as! TrajetTableViewCell
        // Configure the cell...
        print(indexPath.row)
        cell.labelGareDepart.text = trajets[indexPath.row].gareDepart?.name
        cell.labelGareArrive.text = trajets[indexPath.row].gareArrive?.name
        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            db.deleteTrajet(id_trajet: trajets[indexPath.row].id_trajet!)
            reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "DepartView") as! DepartTableViewController
        myVC.trajet = trajets[indexPath.row]
        navigationController?.pushViewController(myVC, animated: true)
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
