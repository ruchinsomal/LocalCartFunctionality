//
//  MedicineListVC.swift
//  APIStorage
//
//  Created by Ruchin Somal on 2021-06-13.
//

import UIKit

class MedicineListVC: UIViewController {
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    
    private let vm = ViewModel()
    private var isPagination: Bool = true
    private var pageSize: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Medicine List"
        configureCell()
        getData()
    }
    
    private func getData() {
        activityIndecator.startAnimating()
        vm.getData { (status, error) in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndecator.stopAnimating()
                if status {
                    self?.tblList.reloadData()
                }
            }
        }
    }
    private func configureCell() {
        tblList.register(UINib(nibName: "MedicineCell" , bundle: Bundle.main), forCellReuseIdentifier: "MedicineCell")
        tblList.tableFooterView = UIView(frame: .zero)
    }
    
    @IBAction func barButtonPressed(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(identifier: "PrescriptionPadVC") as? PrescriptionPadVC else {
            return
        }
        vc.vm = vm
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MedicineListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.arrMedicine.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = vm.arrMedicine[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell", for: indexPath) as? MedicineCell else {
            return UITableViewCell()
        }
        cell.setupCell(forIndexPath: indexPath, withObject: obj)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension MedicineListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.selectedObj = vm.arrMedicine[indexPath.row]
    }
}

extension MedicineListVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        getData()
        isPagination = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            vm.filterData(str: searchText)
            self.tblList.reloadData()
        } else {
            isPagination = true
            getData()
        }
    }
}
extension MedicineListVC : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if scrollView.contentSize.height < scrollView.frame.height {return}
        if bottomEdge >= scrollView.contentSize.height {
            if !isPagination {
                return
            }
            pageSize += vm.pageSize
            isPagination = vm.getDataFromCoredataPagination(pageNo: pageSize)
            self.tblList.reloadData()
        }
    }
}

