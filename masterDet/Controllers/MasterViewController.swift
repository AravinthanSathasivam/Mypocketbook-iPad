//
//  MasterViewController.swift
//  coursework -02
//
//  Created by Aravinthan Sathasivam on 5/16/21.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // create Variables
    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet weak var sortBtn: UIBarButtonItem!
    var expenseViewController: ExpenseViewController? = nil
    var addEditCategoryViewController: AddEditCategotyViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    // category- Array
    var categories: [Category] = []
    var categoryPlaceholder:Category?
    var isEditView:Bool? = false
    var sortingMethod = "clickCount"
    var isAscending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign delegates
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.tableFooterView = UIView()
        categories = Utilities.fetchFromDBContext(entityName: "Category")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newCategory = Category(context: context)
        // Assign values - category
        newCategory.name = "Travel"
        newCategory.budget = 500.00
        newCategory.note = "Note"
        newCategory.categoryId = "blue"
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    // Preapare- Function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            for cell in tableView.visibleCells {
                // Set all the cell border to 0
                let indexPath: IndexPath = tableView.indexPath(for: cell)!
                tableView.cellForRow(at: indexPath)?.layer.borderWidth = 0
            }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                // Set the selected cell border and the border color
                tableView.cellForRow(at: indexPath)?.layer.borderWidth = 3
                tableView.cellForRow(at: indexPath)?.layer.borderColor = UIColor.systemBlue.cgColor
                let controller = (segue.destination as! UINavigationController).topViewController as! ExpenseViewController
                controller.expenseItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                expenseViewController = controller
            }}
        
        if segue.identifier == "categoryPopup" {
            let controller = segue.destination as! AddEditCategotyViewController
            controller.categoryPlaceholder = categoryPlaceholder
            controller.categoryTable = self.tableView
            controller.isEditView = self.isEditView
            addEditCategoryViewController = controller
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        if sectionInfo.numberOfObjects == 0 {
            self.categoryTableView.setEmptyMessage("Category- Empty")
        } else {
            self.categoryTableView.restore()
        }
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
        let category = fetchedResultsController.object(at: indexPath)
        cell.categoryLbl.text = category.name
        cell.budgetLbl.text = "£" + String(category.budget)
        cell.noteLbl.text = category.note
        cell.selectionStyle = .none
        cell.backgroundColor = Utilities.chooseColor(category.color!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
                fatalError("Error - Category not stored!! \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withEvent event: Category) {
        //        cell.textLabel!.text = event.name
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Category> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit - sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: sortingMethod, ascending: isAscending)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit - section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditView = true
            self.categoryPlaceholder = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "categoryPopup", sender: self)
            self.isEditView = false
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemBlue
        return action
    }
    
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete category: " + self.fetchedResultsController.object(at: indexPath).name!, yesAction: {() in
                let context = self.fetchedResultsController.managedObjectContext
                context.delete(self.fetchedResultsController.object(at: indexPath))
                
                self.performSegue(withIdentifier: "showDetail", sender: self)
                
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Error \(nserror), \(nserror.userInfo)")
                }
            }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemRed
        return action
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
            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Category)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Category)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // sort - function
    @IBAction func sort(_ sender: Any) {
        do {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            
            fetchRequest.fetchBatchSize = 20
            
            // number- sorting
            if(sortingMethod == "clickCount"){
                sortBtn.image = UIImage(imageLiteralResourceName: "sort-number")
                sortingMethod = "name"
                isAscending = true
            }else{
                // A- Z sorting
                sortBtn.image = UIImage(imageLiteralResourceName: "sort-a-z")
                sortingMethod = "clickCount"
                isAscending = false
            }
            
            let sortDescriptor = NSSortDescriptor(key: sortingMethod, ascending: isAscending)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            try _fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        }
        catch{
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
