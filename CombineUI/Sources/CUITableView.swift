//
//  CUITableView.swift
//  CombineUI
//
//  Created by pranjal on 2/13/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Combine
import UIKit

public class DiffableDataSource<T: Hashable, I: Hashable>: UITableViewDiffableDataSource<T, I> {
    var sections: [UITableViewSection]!
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].titleForFooter()
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].titleForHeader()
    }
}

public class UITableViewSection: NSObject {
    private(set) var data = [AnyHashable]()
    private(set) var sectionIndex: Int!
    
    private let dataPublisher: AnyPublisher<[AnyHashable], Never>
    private let cellProvider: (UITableView, IndexPath, AnyHashable) -> UITableViewCell
    private let onSelect: ((IndexPath) -> Void)?
    private let leadingSwipeActionsConfiguration: ((IndexPath) -> UISwipeActionsConfiguration?)?
    private let trailingSwipeActionsConfiguration: ((IndexPath) -> UISwipeActionsConfiguration?)?
    private let header: Accessory?
    private let footer: Accessory?
    
    private var subscriptions = Set<AnyCancellable>()
    
    public convenience init<T: Hashable>(
        data: [T],
        cellProvider: @escaping (UITableView, IndexPath, T) -> UITableViewCell,
        onSelect: ((IndexPath) -> Void)? = nil,
        leadingSwipeActionsConfiguration: ((IndexPath) -> UISwipeActionsConfiguration?)? = nil,
        trailingSwipeActionsConfiguration: ((IndexPath) -> UISwipeActionsConfiguration?)? = nil,
        header: Accessory? = nil,
        footer: Accessory? = nil
    ) {
        self.init(
            data: Just(data),
            cellProvider: cellProvider,
            onSelect: onSelect,
            leadingSwipeActionsConfiguration: leadingSwipeActionsConfiguration,
            trailingSwipeActionsConfiguration: trailingSwipeActionsConfiguration,
            header: header,
            footer: footer
        )
    }
    
    public init<T: Hashable, P: Publisher>(
        data: P,
        cellProvider: @escaping (UITableView, IndexPath, T) -> UITableViewCell,
        onSelect: ((IndexPath) -> Void)? = nil,
        leadingSwipeActionsConfiguration: ((IndexPath) -> UISwipeActionsConfiguration?)? = nil,
        trailingSwipeActionsConfiguration: ((IndexPath) -> UISwipeActionsConfiguration?)? = nil,
        header: Accessory? = nil,
        footer: Accessory? = nil
    ) where P.Output == [T], P.Failure == Never {
        self.dataPublisher = data.map { $0 as [AnyHashable] }.eraseToAnyPublisher()
        self.cellProvider = { cellProvider($0, $1, $2 as! T) }
        self.onSelect = onSelect
        self.leadingSwipeActionsConfiguration = leadingSwipeActionsConfiguration
        self.trailingSwipeActionsConfiguration = trailingSwipeActionsConfiguration
        self.header = header
        self.footer = footer
    }

    func attach(to descriptor: UITableViewDescriptor, sectionIndex: Int) {
        self.sectionIndex = sectionIndex
        
        dataPublisher.sink {
            self.data = $0
            descriptor.updateSnapshot()
        }.store(in: &subscriptions)
    }
    
    public enum Accessory: ExpressibleByStringLiteral {
        case text(String)
        case view(UIView)
        
        var text: String? {
            if case let .text(string) = self {
                return string
            }
            
            return nil
        }
        
        var view: UIView? {
            if case let .view(view) = self {
                return view
            }
            
            return nil
        }
        
        public init(stringLiteral value: String) {
            self = .text(value)
        }
    }
}

extension UITableViewSection {
    func cellForRow(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell { cellProvider(tableView, indexPath, data[indexPath.row]) }
    func numberOfRows() -> Int { data.count }
    func titleForFooter() -> String? { footer?.text }
    func titleForHeader() -> String? { header?.text }
    func leadingSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration? { leadingSwipeActionsConfiguration?(indexPath) }
    func trailingSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration? { trailingSwipeActionsConfiguration?(indexPath) }
    func viewForFooter() -> UIView? { footer?.view }
    func viewForHeader() -> UIView? { header?.view }
}

public class UITableViewDescriptor: NSObject {
    var dataSource: DiffableDataSource<Int, AnyHashable>!
    var tableView: UITableView? {
        didSet {
            configureBindings()
        }
    }
    
    private var sections = [UITableViewSection]()
    private let sectionsPublisher: AnyPublisher<[UITableViewSection], Never>
    private var subscriptions = Set<AnyCancellable>()

    public init<T: Publisher>(sections: T) where T.Output == [UITableViewSection], T.Failure == Never {
        self.sectionsPublisher = sections.eraseToAnyPublisher()
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
        snapshot.appendSections(sections.map { $0.sectionIndex })
        
        for section in sections {
            snapshot.appendItems(section.data, toSection: section.sectionIndex)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureBindings() {
        guard let tableView = self.tableView else { return }
        
        dataSource = DiffableDataSource<Int, AnyHashable>(
            tableView: tableView,
            cellProvider: {(tableView, indexPath, data) in
                self.sections[indexPath.section].cellForRow(in: tableView, indexPath: indexPath)
            }
        )
                
        sectionsPublisher.sink {
            self.dataSource.sections = $0
            self.sections = $0
            self.sections.enumerated().forEach { $1.attach(to: self, sectionIndex: $0) }
            tableView.dataSource = self.dataSource
        }.store(in: &subscriptions)
    }
}

extension UITableViewDescriptor: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].numberOfRows()
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        sections[indexPath.section].leadingSwipeActionsConfiguration(for: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        sections[indexPath.section].trailingSwipeActionsConfiguration(for: indexPath)
    }
}

extension UITableView {
    static private let snapshotKey = "snapshot"
    
    public var descriptor: UITableViewDescriptor? {
        get { objc_getAssociatedObject(self, Self.snapshotKey) as? UITableViewDescriptor }
        set {
            objc_setAssociatedObject(self, Self.snapshotKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            
            delegate = newValue
            newValue?.tableView = self
        }
    }
}
