//
//  PrescriptionPadVC.swift
//  APIStorage
//
//  Created by Ruchin Somal on 2021-06-13.
//

import UIKit

class PrescriptionPadVC: UIViewController {
    
    @IBOutlet weak var tblList: UITableView!
    
    var vm = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Prescription Pad"
        configureCell()
        getData()
    }
    
    private func getData() {
        vm.fetchCart()
        tblList.reloadData()
    }
    private func configureCell() {
        tblList.register(UINib(nibName: "MedicineCell" , bundle: Bundle.main), forCellReuseIdentifier: "MedicineCell")
        tblList.tableFooterView = UIView(frame: .zero)
    }
}

extension PrescriptionPadVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.arrCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = vm.arrCart[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell", for: indexPath) as? MedicineCell else {
            return UITableViewCell()
        }
        cell.setupCell(forIndexPath: indexPath, withObject: obj)
        cell.cartZero = { [weak self] status in
            if status {
                self?.getData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PrescriptionPadVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
