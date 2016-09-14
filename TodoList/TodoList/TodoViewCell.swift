//
//  TodoViewCell.swift
//  TodoList
//
//  Created by VuVince on 9/13/16.
//  Copyright © 2016 VuVince. All rights reserved.
//

import UIKit

class TodoViewCell: UITableViewCell {

    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
