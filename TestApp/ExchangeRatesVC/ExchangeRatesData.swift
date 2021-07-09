//
//  ExchangeRatesData.swift
//  TestApp
//
//  Created by Vasiliy Lopatnikov on 07.07.2021.
//

import Foundation

struct Exchanges {
    var exchangeTitle: String?
    var exchangeRate: String
}

enum PARSE_NAME_SPACE : String {
    case parseDate = "Date",
         parseValue = "Value"
}

class ExchangeRatesData: NSObject {
    
    var currentName: String?
    var currentDate: String?
    
    let uniqueExchangeID = "R01235"
    
    var dateFormatter:DateFormatter = {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        return dateFormatterPrint
    }()
    
    var results: [Exchanges]?         // the whole array of dictionaries
        
        func getExchangeRatesFromDates(userCompletionHandler: @escaping ([Exchanges]?, String?) -> Void){
            
            let lastDate = Date().addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
            let firstDate = Calendar.current.date(byAdding: .month, value: -1, to: lastDate)!
            
            
            
            guard let url = URL(string: "http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=\(dateFormatter.string(from: firstDate))&date_req2=\(dateFormatter.string(from: lastDate))&VAL_NM_RQ=\(uniqueExchangeID)") else{return}
            
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession.shared
            
            session.dataTask(with: request) { (data, response, error) in
                if response != nil{
                    
                }
                guard let data = data else{
                    
                    userCompletionHandler(nil, "Fail_Data_Loaded")
                    return
                }
                
                let parser = XMLParser(data: data)
                parser.delegate = self
                if parser.parse() {
                    if let results = self.results{
                        userCompletionHandler(results, nil)
                    }else{
                        userCompletionHandler(nil, "Fail_Parse_Data")
                    }
                }
                print(String(decoding: data, as: UTF8.self))
                
                
            }.resume()
    }
}
extension ExchangeRatesData: XMLParserDelegate{
    func parserDidStartDocument(_ parser: XMLParser) {
        results = []
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "Record"{
            currentDate = attributeDict["Date"]
        }
        currentName = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentName == "Value"{
            let exch = Exchanges(exchangeTitle: currentDate, exchangeRate: string)
            results?.append(exch)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        results?.reverse()
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        results = nil
        currentName = nil
    }
    
}

