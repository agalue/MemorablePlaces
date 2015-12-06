//
//  PlaceViewCell.swift
//  MemorablePlaces
//
//  Created by Alejandro Galue on 12/5/15.
//  Copyright © 2015 Street Dog Studio. All rights reserved.
//

import UIKit

class PlaceViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        // Configure the view for the selected state
    }

    func update(place: Place) {
        nameLabel.text = place.name
        addressLabel.text = place.address
    }
}
