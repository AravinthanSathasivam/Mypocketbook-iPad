//
//  ExpenseViewController.swift
//  coursework -02
//
//  Created by Aravinthan Sathasivam on 5/16/21.
//

import UIKit

class ExpenseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // create Variables - Outlets
    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var budgetAmountLabel: UILabel!
    @IBOutlet weak var spentAmountLabel: UILabel!
    @IBOutlet weak var remainAmountLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var orangeLabel: UILabel!
    @IBOutlet weak var purpleLabel: UILabel!
    @IBOutlet weak var cyanLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var addExpenseBtn: UIBarButtonItem!
    @IBOutlet weak var pieChartViewContainer: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    // create Variables
    var expenseItem:Category?
    var isEditView:Bool? = false
    var expensePlaceholder:Expense?
    var addEditExpenseController: AddEditExpenseViewController? = nil
    let pieChartView = PieChartView()
    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign values - Text Fields
        categoryNameLabel.text = "\(expenseItem?.name ?? "Select Category")"
        budgetAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"
        spentAmountLabel.text = "£ 0.0"
        remainAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"
        // Delegates
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        addcounter()
        // Table View
        expenseTableView.tableFooterView = UIView()
        
        // Styles- variablbes
        let padding: CGFloat = 20
        let height = (pieChartViewContainer.frame.height - padding * 3)
        
        // Assign values -  pie Chart
        pieChartView.frame = CGRect(
            x: 0, y: padding, width: pieChartViewContainer.frame.size.width, height: height
        )

        pieChartView.segments = [
            LabelledSegment(color: #colorLiteral(red: 0.9467689395, green: 0.4717171192, blue: 0.4472602606, alpha: 1), name: "Red",    value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.9585652947, green: 0.8335036635, blue: 0.3131697774, alpha: 1), name: "Yellow", value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.5391305089, green: 0.3921048641, blue: 0.8406239152, alpha: 1), name: "Purple", value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.3722616434, green: 0.5258184075, blue: 0.9463476539, alpha: 1), name: "Blue",   value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.4086512327, green: 0.8929718137, blue: 0.5811446309, alpha: 1), name: "Green",  value: 0)
        ]

        pieChartView.segmentLabelFont = .systemFont(ofSize: 10)
        pieChartViewContainer.addSubview(pieChartView)

        if (expenseItem === nil){
            addExpenseBtn.isEnabled = false
        }
    }
    
    // preapre - function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendCategory" {
            let controller = segue.destination as! AddEditExpenseViewController

            controller.category = self.expenseItem
            controller.expenseTable = self.expenseTableView
            controller.isEditView = self.isEditView
            controller.expensePlaceholder = self.expensePlaceholder
            addEditExpenseController = controller
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //        pieChartView.animateChart()
    }
    
    // Populate - Pie Chart
    func populatePyChart(exps : [Expense], spentAmount : Float){
            resetPieChart()
            let expsR = exps.sorted(by: {$0.amount > $1.amount})
            var other:Float = 0
            var labeltags: [String] = ["Expense-01", "Expense-02", "Expense-03","Expense-04","Others"]

            for (index, element) in expsR.enumerated() {

                if(index < 4){
                    pieChartView.segments[index].value = CGFloat(element.amount/spentAmount*100)
                    labeltags[index] = element.title!
                }else{
                    other += element.amount
                }
            }

            if other > 0  {
                pieChartView.segments[4].value = CGFloat(other/spentAmount*100)
                labeltags[4] = "Other"
            }

            redLabel.text = labeltags[0]
            orangeLabel.text = labeltags[1]
            purpleLabel.text = labeltags[2]
            cyanLabel.text = labeltags[3]
            greenLabel.text = labeltags[4]
        }

    func addcounter(){
        self.expenseItem?.setValue(self.expenseItem!.clickCount + 1, forKey: "clickCount")
        do {
            try self.context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exps = (self.expenseItem?.expenses?.allObjects) as? [Expense] {
            if exps.count == 0 {
                self.expenseTableView.setEmptyMessage("No expenses added for this category!")
            } else {
                resetPieChart()
                self.expenseTableView.restore()
            }
            return exps.count
        }
        return 0
    }

     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }

    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.expenseItem?.expenses?.allObjects) as? [Expense]

        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditView = true
            //            self.cate.image = UIImage(named: "edit")
            self.expensePlaceholder = expenseList![indexPath.row]

            self.performSegue(withIdentifier: "sendCategory", sender: expenseList![indexPath.row])
            self.isEditView = false
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemBlue
        return action
    }
    
    // Delete- Function
    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.expenseItem?.expenses?.allObjects) as? [Expense]


        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete expense: ", yesAction: {
                () in
                print("deleted",expenseList![indexPath.row])

                do {
                    let removingExpense = expenseList![indexPath.row]
                    self.expenseItem?.removeFromExpenses(removingExpense)
                    let context = self.context

                    try context.save()
                    self.expenseTableView.reloadData()
                } catch {

                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemRed
        return action
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expenseTableView.dequeueReusableCell(withIdentifier: "expenseCell") as! ExpenseTableViewCell
        if var expense = (self.expenseItem?.expenses?.allObjects) as? [Expense] {
            let datapoint = expense[indexPath.row]
            cell.titleLbl.text = datapoint.title
            cell.amountLbl.text = "\(datapoint.amount)"
            cell.noteLbl.text = datapoint.notes

            var totalSpent:Float = 0
            for exp in expense {
                totalSpent += exp.amount
            }
            spentAmountLabel.text = "£ \(round(Double(totalSpent) * 100)/100.0)"
            remainAmountLabel.text = "£ \(round((expenseItem!.budget - totalSpent) * 100)/100.0)"
            cell.customProgressBar.progress = CGFloat(expense[indexPath.row].amount/expenseItem!.budget)
            populatePyChart(exps :expense, spentAmount : totalSpent)
        }
        return cell
    }
    
    // Reset - Pie Chart values
    func resetPieChart(){
        pieChartView.segments = [
            LabelledSegment(color: #colorLiteral(red: 0.9467689395, green: 0.4717171192, blue: 0.4472602606, alpha: 1), name: "Red",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.9585652947, green: 0.8335036635, blue: 0.3131697774, alpha: 1), name: "Yellow",  value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.5391305089, green: 0.3921048641, blue: 0.8406239152, alpha: 1), name: "Purple",  value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.3722616434, green: 0.5258184075, blue: 0.9463476539, alpha: 1), name: "Blue",    value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.4086512327, green: 0.8929718137, blue: 0.5811446309, alpha: 1), name: "Green",   value: 0)
        ]
        
        redLabel.text = "Expense-01"
        orangeLabel.text =  "Expense-02"
        purpleLabel.text = "Expense-03"
        cyanLabel.text =  "Expense-04"
        greenLabel.text = "Others"
    }
}
