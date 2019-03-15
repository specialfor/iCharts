//: A UIKit based Playground for presenting user interface
  
import UIKit
import iCharts
import PlaygroundSupport

let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
let view = UIView(frame: rect)
view.backgroundColor = .white

let handlerView = HandlerView(frame: rect)
view.addSubview(handlerView)

print(handlerView.layer.mask?.value(forKey: "path"))

PlaygroundPage.current.liveView = view
