//
//  CategoryTableViewCell
//  coursework -02
//
//  Created by Aravinthan Sathasivam on 5/18/21.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    // create Variables - Outlets
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var budgetLbl: UILabel!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var categoryContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    // set selected - Function
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
