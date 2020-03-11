//
//  ViewController.swift
//  Example
//
//  Created by pranjal on 1/23/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import CombineUI

class ViewController: CUIViewController {
    @IBOutlet var tableView: UITableView!
    
    override func configureBindings() {
        super.configureBindings()
        
        tableView.descriptor = CUITableViewDescriptor(
            sections: Just([
                CUITableViewSection(
                    data: Just([""]),
                    cellProvider: {(a, b, c) in
                        return UITableViewCell()
                    }
                )
            ])
        )
    }
}
