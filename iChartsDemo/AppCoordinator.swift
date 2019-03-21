//
//  AppCoordinator.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit

private let icons: [UIImage] = [#imageLiteral(resourceName: "outline_looks_one_black_24pt"), #imageLiteral(resourceName: "outline_looks_two_black_24pt"), #imageLiteral(resourceName: "outline_looks_3_black_24pt"), #imageLiteral(resourceName: "outline_looks_4_black_24pt"), #imageLiteral(resourceName: "outline_looks_5_black_24pt")]

final class AppCoordinator {
    
    func start(window: UIWindow) {
        let datasets = parseDatasets()
        window.rootViewController = makeNavigationController(datasets: datasets)
        window.makeKeyAndVisible()
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
    
    private func makeNavigationController(datasets: [Dataset]) -> UINavigationController {
        let vc = StatisticsViewController(datasets: datasets)
        vc.title = "Statistics"
        return UINavigationController(rootViewController: vc)
    }
}
