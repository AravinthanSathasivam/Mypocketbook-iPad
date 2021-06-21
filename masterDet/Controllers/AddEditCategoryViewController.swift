//
//  AddEditCategotyViewController.swift
//  CW02
//
//  Created by Aravinthan Sathasivam on 5/17/21.
//

import UIKit

class AddEditCategotyViewController: UIViewController {
    
    // create Variables - Outlets
    @IBOutlet weak var moduleTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var markAwardedTextField: UITextField!
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var levelSegmentControl: UISegmentedControl!
    @IBOutlet weak var addToCalendarToggle: UISwitch!
    @IBOutlet weak var dateSegmentControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var addNotesTextField: UITextField!
    @IBOutlet weak var colorSegmentControl: UISegmentedControl!
    
    // Create - variables
    var saveFunction: Utilities.saveFunctionType?
    var resetToDefaults: Utilities.resetToDefaultsFunctionType?
    var categoryPlaceholder: Category?
    var isEditView:Bool?
    var categories:[Category]?
    var categoryTable:UITableView?
    weak var delegate: ItemActionDelegate?

    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext
    // Array
    let colorsArray = ["Red","Green","Blue","Yellow", "Grey","Purple"]

    override func viewDidDisappear(_ animated: Bool) {
        isEditView=false
        categoryPlaceholder=nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if (isEditView!) {
            if let category = categoryPlaceholder {
                nameTextField.text = category.name
                budgetTextField.text = "\(category.budget)"
                addNotesTextField.text = category.note
                colorSegmentControl.selectedSegmentIndex = colorsArray.firstIndex(of: category.color ?? "Red") ?? 0
            }
        }
        nameTextField.becomeFirstResponder()
    }

    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true);
    }
    
    // save- function - Save Category
    @IBAction func saveButtonPressed(_ sender: Any) {
        if nameTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Name of the Category can't be empty", caller: self)
        } else if budgetTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Budget can't be empty", caller: self)
        } else {
            var newCategory:Category
            if(self.isEditView ?? false){
                newCategory = self.categoryPlaceholder!
            }else{
                newCategory = Category(context: self.context)
                cancelButtonPressed("new")
            }
            newCategory.name = nameTextField.text!
            newCategory.budget = (budgetTextField.text! as NSString).floatValue
            newCategory.note = addNotesTextField.text!
            // set colour value - Based on selected segment Index
            var color = ""
            if colorSegmentControl.selectedSegmentIndex == 0{
                color = "Red"
            }else if colorSegmentControl.selectedSegmentIndex == 1{
                color = "Green"
            }else if colorSegmentControl.selectedSegmentIndex == 2{
                color = "Blue"
            }else if colorSegmentControl.selectedSegmentIndex == 3{
                color = "Yellow"
            }else if colorSegmentControl.selectedSegmentIndex == 4{
                color = "Grey"
            }else if colorSegmentControl.selectedSegmentIndex == 5{
                color = "Purple"
            }
            // add to newCategory
            newCategory.categoryId = UUID().uuidString
            newCategory.color = color
            newCategory.clickCount = 0
            
            // try catch

            do {
                try self.context.save()
                categoryTable?.reloadData()
                cancelButtonPressed("Cancelled")

            } catch {
                let nserror = error as NSError
                fatalError("Error - Cateogry didn't save \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // cancel Button - function
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let reset = resetToDefaults {
            reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
