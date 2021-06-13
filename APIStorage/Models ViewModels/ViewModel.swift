//
//  ViewModel.swift
//  APIStorage
//
//  Created by Ruchin Somal on 2021-06-13.
//

import UIKit
import CoreData

class ViewModel: NSObject {
    let medicineURL = "https://6082d0095dbd2c001757a8de.mockapi.io/api/medicines"
    let pageSize: Int = 10
    var selectedObj: Medicines?
    var arrMedicine: [Medicines] = []
    var arrCart: [Medicines] = []
    
    func getData(callBack: @escaping (Bool, Error?) -> Void) {
        if getDataFromCoredataPagination() {
            callBack(true, nil)
            return
        }
        guard let url = URL(string: medicineURL) else {
            let error = NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "Invalid URL"])
            callBack(false, error as Error)
            return
        }
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data else {
                print(String(describing: error))
                callBack(false, error)
                return
            }
            guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
                callBack(false, error)
                return
            }
            guard let jsonArray = jsonData as? [[String: Any]] else {
                callBack(false, error)
                return
            }
            self?.saveDataToCoredata(jsonArr: jsonArray)
            if self?.getDataFromCoredataPagination() ?? false {
                callBack(true, nil)
                return
            }
        }
        task.resume()
    }
    
    private func saveDataToCoredata(jsonArr: [[String: Any]]) {
        CoreDataManager.shared.truncateEntity(entity: .medicines)
        var arr: [Medicines] = []
        for dict in jsonArr {
        let obj = NSEntityDescription.insertNewObject(forEntityName: EntityName.medicines.rawValue, into: CoreDataManager.shared.managedObjectContext) as? Medicines
            obj?.medicineID = dict["id"] as? Int64 ?? 0
            obj?.name = dict["name"] as? String
            obj?.type = dict["type"] as? String
            obj?.packform = dict["packform"] as? String
            obj?.company = dict["company"] as? String
            obj?.strength = dict["strength"] as? String
            obj?.strengthtype = dict["strengthtype"] as? String
            if let actualObj = obj {
            arr.append(actualObj)
            }
        }
        CoreDataManager.shared.saveContext()
    }
    
    private func getDataFromCoredata() -> Bool {
        guard let arr = CoreDataManager.shared.getAllObject(entity: .medicines) as? [Medicines] else {
            return false
        }
        if arr.count > 0 {
            arrMedicine = arr
        }
        return arr.count > 0
    }
    
    func getDataFromCoredataPagination(pageNo: Int = 0) -> Bool {
        if pageNo == 0 {
            arrMedicine.removeAll()
        }
        guard let arr = CoreDataManager.shared.getAllObjectWithPagination(entity: .medicines, startIndex: pageNo, endIndex: pageSize) as? [Medicines] else {
            return false
        }
        if arr.count > 0 {
            arrMedicine.append(contentsOf: arr)
        }
        return arr.count > 0
    }
    
    func filterData(str: String) {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", str)
        if let object = CoreDataManager.shared.getObjectFor(entity: .medicines, predicate: predicate) as? [Medicines] {
            arrMedicine = object
        } else {
            arrMedicine.removeAll()
        }
    }
    
    func fetchCart() {
        let predicate = NSPredicate(format: "dosage > %d", 0)
        if let object = CoreDataManager.shared.getObjectFor(entity: .medicines, predicate: predicate) as? [Medicines] {
            arrCart = object
        } else {
            arrCart.removeAll()
        }
    }
}
