//
//  Delegate.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

extension DetailedChartView {
    
    final class Delegate: NSObject, UITableViewDelegate {
        
        var props: [CellProps] = []
        
        var didCellSelected: ((IndexPath) -> Void)?
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cell.imageView?.layer.cornerRadius = 4.0
            cell.imageView?.layer.masksToBounds = true
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            props[indexPath.row].isChecked.value.toggle()
            didCellSelected?(indexPath)
        }
    }
}
