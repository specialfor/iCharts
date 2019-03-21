//
//  Datasource.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

extension DetailedChartView {
    
    final class Datasource: NSObject, UITableViewDataSource {
        
        var titleColor: UIColor = .black
        
        var props: [CellProps]
        let identifier: String
        
        init(props: [CellProps] = [], identifier: String) {
            self.props = props
            self.identifier = identifier
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return props.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            configure(cell: cell, at: indexPath)
            return cell
        }
        
        private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = titleColor
            
            let cellProps = props[indexPath.row]
            cellProps.title.bind { cell.textLabel?.text = $0 }
            cellProps.color.bind { [weak self] in
                guard let self = self else { return }
                cell.imageView?.image = UIImage(color: $0, size: self.imageSize(for: cell))
            }
            cellProps.isChecked.bind { cell.accessoryType = $0 ? .checkmark : .none }
        }
        
        func imageSize(for cell: UITableViewCell) -> CGSize {
            let side = 6
            return CGSize(width: side, height: side)
        }
    }
}
