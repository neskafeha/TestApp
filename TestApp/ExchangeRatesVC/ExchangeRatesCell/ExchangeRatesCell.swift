//
//  ExchangeRatesCell.swift
//  TestApp
//
//  Created by Vasiliy Lopatnikov on 07.07.2021.
//

import UIKit

class ExchangeRatesCell: UITableViewCell {

    @IBOutlet weak var l_shortTitle: UILabel!
    @IBOutlet weak var l_fullTitle: UILabel!
    @IBOutlet weak var l_exchangeValue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
