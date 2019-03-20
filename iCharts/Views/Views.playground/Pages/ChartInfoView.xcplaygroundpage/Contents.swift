//: [Previous](@previous)

import UIKit
import iCharts
import PlaygroundSupport

let rect = CGRect(origin: .zero, size: CGSize(width: 300, height: 80))

let view = ChartInfoView(frame: rect)
view.render(props: .init(
    dateMonth: "Dec 17",
    year: "2019",
    lineValues: [
        .init(value: "150", color: .red),
        .init(value: "30000", color: .green),
        .init(value: "150", color: .red),
        .init(value: "30000", color: .green),
        .init(value: "150", color: .red),
        .init(value: "30000", color: .green),
        .init(value: "150", color: .red),
        .init(value: "30000", color: .green),
        ]))

PlaygroundPage.current.liveView = view

//: [Next](@next)
