//
//  TTableView.swift
//  Starateli
//
//  Created by Virpik on 29/12/2016.
//  Copyright © 2016 Sybis. All rights reserved.
//

import UIKit

public extension UITableView{
    public func register(atClass:AnyClass){
        let idendifier = self.cellIdendifier(atClass: atClass);
        let nib = UINib(nibName: "\(atClass)", bundle: nil);
        self.register(nib, forCellReuseIdentifier: idendifier);
    }
    
    public func cell(atClass:AnyClass)->UITableViewCell?{
        return self.dequeueReusableCell(withIdentifier: self.cellIdendifier(atClass: atClass));
    }
    
    public func cellIdendifier(atClass:AnyClass) -> String {
        return "\(atClass)";
    }
}


public protocol TTableViewRowInterfase{
    var identifier:String? {get};
    var cellClass:AnyClass {get};
    var expanded:Bool {get set};
    
    func build(cell:UITableViewCell, indexPath:IndexPath)
}

public protocol TTableViewRowModel{}

public class TTableView:NSObject, UITableViewDataSource, UITableViewDelegate{
    public private(set) var tableView:UITableView;
    public private(set) var sections:[TTableViewSection] = []
    
    private var registersCell:[String:Bool] = [:];
    private var cachesHeightCell:[IndexPath:CGFloat] = [:];
    
    public var delegate:UITableViewDelegate?;
    
    public init(tableView:UITableView) {
        self.tableView = tableView;
        
        super.init();

        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    
    public func setupAutomaticDimension(){
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 150;
    }
    
    public func expand(atSection:Int, rows: Int...){
        self.expand(atSection:atSection, rows:rows);
    }
    
    public func collapse(atSection:Int, rows: Int...){
        self.collapse(atSection:atSection, rows:rows);
    }
    
    public func expand(atSection:Int, rows: [Int]){
        let really = self.sections[atSection].expandRows(rows);
        let indexPaths = self.indexsToPath(section: atSection, indexs:really);
        
        if (indexPaths.count == 0) {return}
    
        let offset = self.tableView.contentOffset;
        
        self.tableView.contentOffset = offset;
        
        self.tableView.beginUpdates();
        self.tableView.insertRows(at: indexPaths, with: .top);
        self.tableView.endUpdates();
    }
    
    public func collapse(atSection:Int, rows: [Int]){
        let really = self.sections[atSection].collapseRows(rows);
        let indexPaths = self.indexsToPath(section: atSection, indexs:really);
        
        if (indexPaths.count == 0) {return}
        
        self.tableView.beginUpdates();
        self.tableView.deleteRows(at: indexPaths, with: .top);
        self.tableView.endUpdates();
    }
    
    public func append(section:TTableViewSection, index:Int? = nil){
        var _index = self.sections.count;
        
        if let tIndex = index{
            _index = tIndex
        }
        
        self.sections.insert(section, at: _index);
        
        section.rows.forEach { (row) in
            self.checkRegistraionCell(cellClass: row.cellClass);
        }
    }
    
    private func indexsToPath(section:Int, indexs:[Int])->[IndexPath]{
        var result:[IndexPath] = [];
        
        indexs.forEach { (index) in
            let indexPath = IndexPath(row: index, section: section);
            result.append(indexPath);
        }
        
        return result;
    }
    
    private func checkRegistraionCell(cellClass:AnyClass){
        let cellId = self.tableView.cellIdendifier(atClass: cellClass);
        
        if self.registersCell[cellId] != nil { return }
        
        self.tableView.register(atClass: cellClass);
        
        self.registersCell[cellId] = true;
    }
    
    // MARK table View delegate
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        self.cachesHeightCell[indexPath] = cell.frame.height;
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath){
        self.delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let heightForRowAt = self.delegate?.tableView?(tableView, heightForRowAt: indexPath) {
            if (heightForRowAt > 0){
                return heightForRowAt;
            }
        }
        
        return self.tableView.rowHeight;
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let heightForHeaderInSection = self.delegate?.tableView?(tableView, heightForHeaderInSection: section) {
            
            return heightForHeaderInSection;
            
        }
        return self.tableView.sectionHeaderHeight;
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        
        if let heightForFooterInSection = self.delegate?.tableView?(tableView, heightForHeaderInSection: section) {
            return heightForFooterInSection;
        }
        
        return self.tableView.sectionFooterHeight;
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let estimatedHeightForRowAt = self.delegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) {
            return estimatedHeightForRowAt;
        }
        
        if (self.tableView.rowHeight == UITableViewAutomaticDimension) {
            if let cachesHeightCell = self.cachesHeightCell[indexPath] {
                if (cachesHeightCell > 0){
                    return cachesHeightCell;
                }
            }
        }
        
        return self.tableView.estimatedRowHeight;
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        if let estimatedHeightForHeaderInSection = self.delegate?.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
            return estimatedHeightForHeaderInSection;
        }
        
        return self.tableView.estimatedSectionHeaderHeight;
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let estimatedHeightForFooterInSection = self.delegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) {
            return estimatedHeightForFooterInSection;
        }
        
        return self.tableView.estimatedSectionFooterHeight;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.tableView?(tableView, didSelectRowAt: indexPath);
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.delegate?.tableView?(tableView, didDeselectRowAt: indexPath);
    }

    
    // MARK table View data Sourse
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView != self.tableView {
            return 0
        }
        
        return sections.count;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != self.tableView { return 0}
        
        return self.sections[section].numberRows;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if tableView != self.tableView { return UITableViewCell();}
        
        let section = self.sections[indexPath.section];
        
        let row = section.rows[indexPath.row];
        
        let cell = self.tableView.cell(atClass:row.cellClass)!;
        
        row.build(cell: cell, indexPath:indexPath);
        
        return cell;
    }
    
}

extension TTableView{
    public func according(expand:Bool, atSection:Int, rows: Int...){
        self.according(expand: expand, atSection:atSection, rows: rows);
    }
    
    public func according(expand:Bool, atSection:Int, rows: [Int]){
        if (expand){
            self.expand(atSection: atSection, rows: rows);
        }else{
            self.collapse(atSection: atSection, rows: rows);
        }
    }
}
