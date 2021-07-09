//
//  ExchangeRatesVC.swift
//  TestApp
//
//  Created by Vasiliy Lopatnikov on 07.07.2021.
//

import UIKit

class ExchangeRatesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items:[Exchanges]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ExchangeRatesCell", bundle: nil), forCellReuseIdentifier: "ExchangeRatesCell")
        getDataFromServer()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dayWasChanged),
                                               name: .NSCalendarDayChanged,
                                               object: nil)
    }
    
    func getDataFromServer(dayWasChanged: Bool = false){
        ExchangeRatesData().getExchangeRatesFromDates { (ExchangesData, Error) in
            if let error = Error{
                print(error)
            }else if let data = ExchangesData{
                self.items = data
                let defaults = UserDefaults.standard
                if let lastDate = self.items?.first?.exchangeTitle{
                    if dayWasChanged{
                        defaults.set(lastDate, forKey: "LastDate")
                        self.pushNotification()
                    }else{
                        if let lastSaveDate = defaults.value(forKey: "LastDate") as? String{
                            if lastSaveDate != lastDate{
                                defaults.set(lastDate, forKey: "LastDate")
                            }else{
                                self.pushNotification()
                            }
                        }else{
                            defaults.set(lastDate, forKey: "LastDate")
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    func pushNotification(){
        if let items = self.items{
            if items.count > 1{
                let currentRate:Double = Double(items[0].exchangeRate.replacingOccurrences(of: ",", with: ".")) ?? 0.0
                let previousRate:Double = Double(items[1].exchangeRate.replacingOccurrences(of: ",", with: ".")) ?? 0.0
                if currentRate > previousRate{
                    let center = UNUserNotificationCenter.current()
                    var cal = Calendar.current
                    cal.timeZone = TimeZone(identifier: "UTC")!
                    
                    let fireDate = Date().addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
                    let content = UNMutableNotificationContent()
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone(identifier: "UTC")!
                    let triggerDaily = calendar.dateComponents([.hour,.minute,.second,.day,.month,.year,], from: fireDate)

                    content.title = "Курс увеличился"
   
                    content.body = "Со вчерашнего дня курс валюты за которой Вы следите вырос!"
                    content.sound = UNNotificationSound.default
                    content.badge = 0

                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)
                    
                    let final = UNNotificationRequest(identifier: "ratesWasUpped", content: content, trigger: trigger)

                    center.add(final, withCompletionHandler: nil)
                    
                    
                    
                }
            }
        }
    }
    
    @objc func dayWasChanged(){
        getDataFromServer()
        pushNotification()
    }
    
}
extension ExchangeRatesVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeRatesCell") as? ExchangeRatesCell else{
            return UITableViewCell()
        }
        cell.l_shortTitle.text = "USD"
        cell.l_fullTitle.text = items?[indexPath.row].exchangeTitle
        cell.l_exchangeValue.text = items?[indexPath.row].exchangeRate
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
}
