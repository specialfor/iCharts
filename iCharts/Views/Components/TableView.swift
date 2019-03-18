//
//  TableVIew.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

class AutoSizableTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
