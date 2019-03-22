//
//  AutoSizableTableView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit

public final class AutoSizableTableView: UITableView {
    
    public override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
