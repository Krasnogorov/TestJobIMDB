//
//  FilmListViewController.swift
//  TestTaskIMDB
//
//  Created by Sergey Krasnogorov on 11/7/19.
//  Copyright © 2019 Sergey Krasnogorov. All rights reserved.
//

import UIKit
import CoreData

class FilmListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: FilmDetailsViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    private var _currentPageIndex : Int = 0
    private var _leftButton : UIBarButtonItem? = nil
    private var _rightButton : UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _currentPageIndex = 1
        MakeRequest()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? FilmDetailsViewController
        }
        
        _leftButton = UIBarButtonItem( title : "PrevPage",style:UIBarButtonItem.Style.plain, target: self, action: #selector(leftButtonClicked(_:)))
        navigationItem.leftBarButtonItem = _leftButton
        _leftButton!.isEnabled = false
        
        _rightButton = UIBarButtonItem(title : "NextPage", style:UIBarButtonItem.Style.plain, target: self, action: #selector(rightButtonClicked(_:)))
        navigationItem.rightBarButtonItem = _rightButton
    }
    
    @objc func leftButtonClicked(_ sender: Any){
        if (_currentPageIndex > 1) {
            _currentPageIndex -= 1
            MakeRequest()
        }
        _leftButton!.isEnabled = (_currentPageIndex != 1)
    }
    
    @objc func rightButtonClicked(_ sender: Any){
        _currentPageIndex += 1
        _leftButton!.isEnabled = (_currentPageIndex != 1)
        MakeRequest()
    }

    func MakeRequest() {
        NetworkManager.SharedInstance().MakeGetRequest(urlPath: NetworkManager.BASE_WEB_ADDRESS + "\(_currentPageIndex)",
                                                       Callback: { (response, error) in
            if (response != nil) {
                let parsedResult: FilmList = try! JSONDecoder().decode(FilmList.self, from: response!)
                for film in parsedResult.items {
                    self.insertNewObject(film);
                }
            }
            else {
                let alert = UIAlertController(title: "Alert", message: error! + NSLocalizedString("Information will be displayed from local database.", comment: ""),
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        });
    }
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let film = sender as! Film;
        if ((fetchedResultsController.fetchedObjects?.contains(where: { (record) -> Bool in
            return record.filmID == film.id }))!) {
            return
        }
        let newFilm = FilmRecord(context: context)
             
        // If appropriate, configure the new managed object.
        newFilm.filmID = Int64(film.id)
        newFilm.filmName = film.title
        newFilm.filmPoster = film.poster
        newFilm.filmDescription = film.description
        // Save the context.
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! FilmDetailsViewController
                controller.detailItem = object
                controller.managedContext = self.managedObjectContext
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent film : FilmRecord) {
        cell.textLabel!.text = film.filmName
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<FilmRecord> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<FilmRecord> = FilmRecord.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "filmIsFavourite", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<FilmRecord>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! FilmRecord)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! FilmRecord)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

