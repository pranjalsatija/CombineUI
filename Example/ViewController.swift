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
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    @Published
    var data = [Int]()
    
    override func configureBindings() {
        super.configureBindings()
        
        addButton.publisher(for: .touchUpInside)
            .sink { _ in self.data.append((self.data.last ?? 0) + 1) }
            .store(in: &cancellables)
        
        tableView.descriptor = CUITableViewDescriptor(
            sections: Just([
                CUITableViewSection(
                    data: self.$data,
                    cellProvider: {(tableView, indexPath, element) in
                        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                        cell.textLabel?.text = String(element)
                        return cell
                    }
                )
            ])
        )
    }
}
