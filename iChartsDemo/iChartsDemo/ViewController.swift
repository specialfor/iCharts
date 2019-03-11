//
//  ViewController.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    lazy var label: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.right.equalToSuperview().inset(16)
        }
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        label.text = "Hello, World!"
        
        let startDate = Date()
        let datasets = parseDatasets()
        let endDate = Date()
        
        let timeinterval = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        print(timeinterval)
    }
    
    private func parseDatasets() -> [Dataset] {
        guard let filePath = Bundle.main.path(forResource: "chart_data", ofType: "json") else {
            return []
        }
        
        do {
            let datasets = try DatasetJSONParser().parse(from: filePath)
            return datasets
        } catch {
            print(error)
            return []
        }
    }
}

