//
//  MedicineCell.swift
//  APIStorage
//
//  Created by Ruchin Somal on 2021-06-13.
//

import UIKit

class MedicineCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!

    var medicineObj: Medicines?
    var cartZero: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(forIndexPath indexPath: IndexPath = IndexPath(row: 0, section: 0), withObject obj: Any? = nil) {
        self.selectionStyle = .none
        if let cObj = obj as? Medicines {
            medicineObj = cObj
            nameLabel.text = cObj.name ?? ""
            typeLabel.text = cObj.type ?? ""
            companyLabel.text = cObj.company ?? ""
            countLabel.text = "\(medicineObj?.dosage ?? 0)"
        }
    }
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        if medicineObj?.dosage ?? 0 == 0 {
            return
        }
        medicineObj?.dosage -= 1
        countLabel.text = "\(medicineObj?.dosage ?? 0)"
        CoreDataManager.shared.saveContext()
        if medicineObj?.dosage ?? 0 == 0 {
            cartZero?(true)
        }
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        medicineObj?.dosage += 1
        countLabel.text = "\(medicineObj?.dosage ?? 0)"
        CoreDataManager.shared.saveContext()
    }
    
}
