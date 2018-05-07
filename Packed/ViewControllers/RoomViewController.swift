//
//  RoomViewController.swift
//  Move
//
//  Created by Jake Gray on 5/7/18.
//  Copyright © 2018 Jake Gray. All rights reserved.
//

import UIKit
import CoreData

class RoomViewController: MainViewController {
    
    var place: Place?
    
    let RoomsFetchedResultsController: NSFetchedResultsController<Room> = {
        let request: NSFetchRequest<Room> = Room.fetchRequest()
        
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: "name", cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rooms"
        RoomsFetchedResultsController.delegate = self
        
        try? RoomsFetchedResultsController.performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        try? RoomsFetchedResultsController.performFetch()
        
        if RoomsFetchedResultsController.fetchedObjects?.count != nil && (RoomsFetchedResultsController.fetchedObjects?.count)! > 0 {
            noDataLabel.isHidden = true
            instructionLabel.isHidden = true
        }
    }
    
    @objc override func addButtonPressed() {
        super.addButtonPressed()
        
//        let newRoomViewController = RoomDetailViewController()
//        navigationController?.pushViewController(newRoomViewController, animated: true)
    }
    
    // MARK: - Cell Delegate
    
    override func cellOptionsButtonPressed(sender: UITableViewCell) {
        let indexPath = mainTableView.indexPath(for: sender)
        let room = RoomsFetchedResultsController.object(at: indexPath!)
        print("options pressed for \(room.name!)")
        let actionSheet = UIAlertController(title: room.name, message: nil, preferredStyle: .actionSheet)
        let updateAction = UIAlertAction(title: "Edit this Room", style: .default) { (_) in
//            let roomDetailViewController = RoomDetailViewController()
//            roomDetailViewController.room = room
//            self.navigationController?.pushViewController(roomDetailViewController, animated: true)
        }
        actionSheet.addAction(updateAction)
        let deleteAction = UIAlertAction(title: "Delete \(room.name!)", style: .destructive) { (_) in
            PlaceController.delete(room: room)
            
        }
        actionSheet.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - TableView Data
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return RoomsFetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RoomsFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = mainTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PackedTableViewCell else {return PackedTableViewCell()}
        
        let room = RoomsFetchedResultsController.object(at: indexPath)
        cell.setupCell(name: room.name!, image: #imageLiteral(resourceName: "RoomIcon"))
        cell.delegate = self
        
        return cell
    }
}

extension RoomViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        mainTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        mainTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .delete:
            mainTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            mainTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            mainTableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            mainTableView.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet.init(integer: sectionIndex)
        switch type {
        case .delete:
            mainTableView.deleteSections(indexSet, with: .automatic)
        case .insert:
            mainTableView.insertSections(indexSet, with: .automatic)
        default:
            print("Can't edit sections like that")
        }
    }
}
