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
    var sections: [CUITableViewSection]!
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let leadingSwipeActions = sections[indexPath.section].leadingSwipeActionsConfiguration(for: indexPath)
        let trailingSwipeActions = sections[indexPath.section].trailingSwipeActionsConfiguration(for: indexPath)
        
        return (leadingSwipeActions != nil) || (trailingSwipeActions != nil)
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].titleForFooter()
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].titleForHeader()
    }
}

public class CUITableViewSection: NSObject {
    private(set) var data = [AnyHashable]()
    private(set) weak var descriptor: CUITableViewDescriptor?
    private(set) var sectionIndex: Int = 0
    
    private let dataPublisher: AnyPublisher<[AnyHashable], Never>
    private let cellProvider: (UITableView, IndexPath, AnyHashable) -> UITableViewCell
    private let onSelect: ((UITableView, IndexPath, AnyHashable) -> Void)?
    private let leadingSwipeActionsConfiguration: ((IndexPath, AnyHashable) -> UISwipeActionsConfiguration?)?
    private let trailingSwipeActionsConfiguration: ((IndexPath, AnyHashable) -> UISwipeActionsConfiguration?)?
    private let header: Accessory?
    private let footer: Accessory?
    
    private var subscriptions = Set<AnyCancellable>()
    
    public init<T: Hashable, P: Publisher>(
        data: P,
        cellProvider: @escaping (UITableView, IndexPath, T) -> UITableViewCell,
        onSelect: ((UITableView, IndexPath, T) -> Void)? = nil,
        leadingSwipeActionsConfiguration: ((IndexPath, T) -> UISwipeActionsConfiguration?)? = nil,
        trailingSwipeActionsConfiguration: ((IndexPath, T) -> UISwipeActionsConfiguration?)? = nil,
        header: Accessory? = nil,
        footer: Accessory? = nil
    ) where P.Output == [T], P.Failure == Never {
        self.dataPublisher = data.map { $0 as [AnyHashable] }.eraseToAnyPublisher()
        self.cellProvider = { cellProvider($0, $1, $2 as! T) }
        self.onSelect = { onSelect?($0, $1, $2 as! T) }
        self.leadingSwipeActionsConfiguration = { leadingSwipeActionsConfiguration?($0, $1 as! T) }
        self.trailingSwipeActionsConfiguration = { trailingSwipeActionsConfiguration?($0, $1 as! T) }
        self.header = header
        self.footer = footer
    }

    func attach(to descriptor: CUITableViewDescriptor, sectionIndex: Int) {
        self.descriptor = descriptor
        self.sectionIndex = sectionIndex
    }
    
    func startListening() {
        dataPublisher.sink {
            self.data = $0
            self.descriptor?.updateSnapshot()
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

extension CUITableViewSection {
    func cellForRow(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell { cellProvider(tableView, indexPath, data[indexPath.row]) }
    func numberOfRows() -> Int { data.count }
    func onSelect(in tableView: UITableView, indexPath: IndexPath) { onSelect?(tableView, indexPath, data[indexPath.row]) }
    func titleForFooter() -> String? { footer?.text }
    func titleForHeader() -> String? { header?.text }
    func leadingSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration? { leadingSwipeActionsConfiguration?(indexPath, data[indexPath.row]) }
    func trailingSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration? { trailingSwipeActionsConfiguration?(indexPath, data[indexPath.row]) }
    func viewForFooter() -> UIView? { footer?.view }
    func viewForHeader() -> UIView? { header?.view }
}

public class CUITableViewDescriptor: NSObject {
    var dataSource: DiffableDataSource<Int, AnyHashable>!
    var tableView: UITableView? {
        didSet {
            configureBindings()
        }
    }
    
    private var isFirstUpdate = true
    private var sections = [CUITableViewSection]()
    private let sectionsPublisher: AnyPublisher<[CUITableViewSection], Never>
    private var subscriptions = Set<AnyCancellable>()

    public init<T: Publisher>(sections: T) where T.Output == [CUITableViewSection], T.Failure == Never {
        self.sectionsPublisher = sections.eraseToAnyPublisher()
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
        snapshot.appendSections(sections.map { $0.sectionIndex })
        
        for section in sections {
            snapshot.appendItems(section.data, toSection: section.sectionIndex)
        }
        
        dataSource.apply(snapshot, animatingDifferences: !isFirstUpdate)
        isFirstUpdate = false
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
            self.sections.forEach { $0.startListening() }
            tableView.dataSource = self.dataSource
        }.store(in: &subscriptions)
    }
}

extension CUITableViewDescriptor: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].onSelect(in: tableView, indexPath: indexPath)
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
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sections[section].viewForHeader()
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        sections[section].viewForFooter()
    }
}

extension UITableView {
    static private let snapshotKey = "snapshot"
    
    public var descriptor: CUITableViewDescriptor? {
        get { objc_getAssociatedObject(self, Self.snapshotKey) as? CUITableViewDescriptor }
        set {
            objc_setAssociatedObject(self, Self.snapshotKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            
            delegate = newValue
            newValue?.tableView = self
        }
    }
}
