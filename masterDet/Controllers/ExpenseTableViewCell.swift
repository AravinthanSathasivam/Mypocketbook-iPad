//
//  ExpenseTableViewCell.swift
//  coursework -02
//
//  Created by Aravinthan Sathasivam on 5/17/21.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    
    // variables - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var occurenceLbl: UILabel!
    @IBOutlet weak var reminderSetLbl: UILabel!
    @IBOutlet weak var customProgressBar: PlainHorizontalProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // setSelected function
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
