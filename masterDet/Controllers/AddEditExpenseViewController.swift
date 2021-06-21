//
//  AddEditExpenseViewController.swift
//  CW02
//
//  Created by Aravinthan Sathasivam on 5/18/21.
//

import UIKit
import EventKit
import EventKitUI

class AddEditExpenseViewController: UIViewController, EKEventEditViewDelegate  {

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }

    let eventStore = EKEventStore()
    var time = Date()
    // create Variables - Outlets
    @IBOutlet weak var expenseTitleTextField: UITextField!
    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var addToCalendarToggle: UISwitch!
    @IBOutlet weak var expenseDate: UIDatePicker!
    @IBOutlet weak var selectedOccurance: UISegmentedControl!
    
    // create Variables
    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    var expenses:[Expense]?
    var category:Category?
    var expenseTable:UITableView?
    var isEditView:Bool? = false
    var expensePlaceholder:Expense?
    //var tableView: UITableView

    weak var delegate: ItemActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        addToCalendarToggle.isOn = false

        if (isEditView!) {
            if let expense = expensePlaceholder {
                        expenseTitleTextField.text = expense.title
                expenseAmountTextField.text = "\(expense.amount)"
                notesTextField.text = expense.notes
                addToCalendarToggle.isOn = expense.reminderflag
                expenseDate.date = expense.date!
                selectedOccurance.selectedSegmentIndex =  Int(expense.occurence)


                    }
        }
        // Do any additional setup after loading the view.
        expenseTitleTextField.becomeFirstResponder()
    }
    
    // clear - function
    func clearField(){
        self.expenseTitleTextField.text = ""
        self.expenseAmountTextField.text = ""
        self.notesTextField.text = ""
    }
    
    // Save function
    @IBAction func save(_ sender: UIBarButtonItem) {
        if expenseTitleTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Expense Title field is empty!!", caller: self)
        } else if expenseAmountTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Expense amount Field is empty!!", caller: self)
        } else {
            var newExpense = Expense(context: self.context)
            if(self.isEditView ?? false){
                newExpense = self.expensePlaceholder!

            }else{
                newExpense = Expense(context: self.context)
                cancelExpense("cancel")

            }
            
            // Store data to Core Data
            newExpense.title = expenseTitleTextField.text!
            newExpense.amount = (expenseAmountTextField.text! as NSString).floatValue
            newExpense.date = expenseDate.date
            newExpense.occurence = Int64(selectedOccurance.selectedSegmentIndex)
            newExpense.notes = notesTextField.text!
            newExpense.reminderflag = addToCalendarToggle.isOn

            category?.addToExpenses(newExpense)
            
            // check toggle is on - Add to Calender
            if addToCalendarToggle.isOn{
                eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                    DispatchQueue.main.async {
                        if (granted) && (error == nil) {
                            // create and store - calendar event
                            let event = EKEvent(eventStore: self.eventStore)
                            event.title = self.expenseTitleTextField.text
                            event.startDate = self.expenseDate.date
                            event.notes = self.notesTextField.text
                            event.endDate = self.expenseDate.date
                            event.calendar = self.eventStore.defaultCalendarForNewEvents

                            let selectedOccurenceValue = self.selectedOccurance.titleForSegment(at: self.selectedOccurance.selectedSegmentIndex)
                            var rule: EKRecurrenceFrequency? = nil
                            switch selectedOccurenceValue! {
                            case "One Off":
                                rule = nil
                            case "Daily":
                                rule = .daily
                            case "Weekly":
                                rule = .weekly
                            case "Monthly":
                                rule = .monthly
                            default:
                                rule = nil
                            }

                            if rule != nil {
                                let recurrenceRule = EKRecurrenceRule(recurrenceWith: rule!, interval: 1, end: nil)
                                event.addRecurrenceRule(recurrenceRule)
                            }

                            do {
                                try self.eventStore.save(event, span: .thisEvent)
                            } catch let error as NSError {
                                fatalError("Failed to save event with error : \(error)")
                            }
                        }else{
                            fatalError("Failed to save event with error : \(String(describing: error)) or access not granted")
                        }
                    }
                })
            }

            do {
                try self.context.save()

                let alert = UIAlertController(title: "Success", message: "Expense Saved!!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))

                self.present(alert, animated: true) {
                    self.clearField()
                }

                expenseTable?.reloadData()

            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    //Cancel - function
    @IBAction func cancelExpense(_ sender: Any) {
        dismiss(animated: true)
    }

    func getExpense() {
        let e = (category?.expenses?.allObjects) as! [Expense]
        e.forEach{exp in print(exp.amount)}
    }
}
