# iCharts 

![Swift version](https://img.shields.io/badge/Swift-4.2-orange.svg) 
[![Cocoapods](https://img.shields.io/cocoapods/p/iCharts.svg)](https://cocoapods.org/pods/iCharts)
[![License](https://img.shields.io/cocoapods/l/iCharts.svg)](https://github.com/specialfor/iCharts/blob/master/LICENSE)
[![Twitter](https://img.shields.io/badge/-@specialfor__ios-blue.svg?style=social&logo=twitter)](https://twitter.com/specialfor_ios)
[![Telegram](https://img.shields.io/badge/-@specialforwork-blue.svg?style=social&logo=telegram)](https://t.me/specialforwork)

The solution for Telegram "March Coding Competition".
Completely implemented using [Core Animation](https://developer.apple.com/documentation/quartzcore) and Auto Layout ([NSLayoutAnchor](https://developer.apple.com/documentation/uikit/nslayoutanchor)).

You may take part in beta testing on [TestFlight](https://testflight.apple.com/join/oV32hPvi).

![Demo Gif](https://thumbs.gfycat.com/FlakyHardtofindFly.webp)

## Telegram "March Coding Competition" tasks

- [x] Use date from [chart_data.json](https://github.com/specialfor/iCharts/blob/master/Shared/Resources/chart_data.json) as input for your charts
- [x] Show all 5 charts on one screen
- [x] Implement **Day/Night** mode
- [x] Add pan gesture on chart in order to highlight points at `x` and watch detailed information
- [x] Show `date` labels bellow `x` axis
- [x] Show `value` labels before `y` axis
- [x] Create `expandable slider control` in order to select visible part of chart and its scale.
- [x] Show visible part of [Xi, Xj] in [minY, maxY] segment with vertical insets at top and bottom, where minY = {y | y <= f(x), x in [Xi, Xj]}, maxY = {y | y >= f(x), x in [Xi, Xj]}
- [ ] Animate `value` labels changing
- [ ] Animate `date` labels changing
- [x] Animate appearance/dissappearance of lines on chart


## Usage

The simplest case is shown below. You should just create props with array of `Line`s and pass it into `render(props:)` method.

```
let chartView = DetailedChartView() // ChartScrollView, PannableChartView, ChartView

// Frame based layout or Auto Layout

let props = ChartView.Props(lines: [
              Line(title: "#1", xs: [1, 2, 3], ys: [3, 4, 5], color: .red),
              Line(title: "#2", xs: [1, 2, 3], ys: [5, 4, 3], color: .green)
            ])

chartView.render(props: props)

```

In order to change theme you should just change `Colors` property.

```
chartView.colors = makeColors() // you should write `makeColors` method, it is just example
```

### ChartView.Props properties

- `lines` - an array of `Line` structs
- `lineWidth` - a positive real value which defines width of line on chart
- `highlithedX` - a `x` coordinate which user highlight on `PannableChartView`
- `estimatedGridSpace` - estimated space between 2 horizontal lines of grid
- `estimatedXLabelWidth` - estimated width of label below `x` axis
- `inset` - vertical inset when user renders chart as full-sized
- `isInFullSize` - determines that should we render chart as full-sized
- `range` - the range of visible part of chart in percents or points
- `didHighlightX` - closure which fires when user highlight points on `PannableChartView`

### Colors

It is not necessary to enumerate all properties of `Colors` struct of each component here. You should just know, that you can change color of any part of chart.

[See `Colors` struct in `DetailedChartView` for more information.](https://github.com/specialfor/iCharts/blob/13c2a0fee782e9e602a9c897d62006e1b36d629e/iCharts/Views/Charts/DetailedChartView/DetailedChartView.swift#L143)


## Instalation

### Cocoapods

To install iCharts via CocoaPods, add the following line to your Podfile:

```
target 'MyAppName' do
  pod 'iCharts'
  use_frameworks!
end
```

Enter `pod try iCharts` in terminal in order to retrieve demo application sources.


## Architecture

**TL;DR**

- fully implemented on `CALayer`s
- preferred composition over inheritance
- fully data-driven UI
- render only visible part of a chart

**Details**

The implementation of `iCharts` framework is highly motivated by `Core Animaton` `CALayer`s capabilities and classes composition instead of inheritance in order to have flexible, extendable and easy-maintainable code base with SRP principle in the head.

**Note:** of course in competition situation with time boundaries it is very hard to find trade offs between speed and quality, that's why some principles of SOLID are violated sometime.

Also it should be remarked that all parts of UI are data-driven. `Props` is used as a dumb representation of UI state at each point of time. This approach makes possible to implement **[time-traveling debugging](https://github.com/calesce/redux-slider-monitor)** feature in future. 

**ChartView.Props example**

```
extension ChartView {

  public struct Props {
    public var lines: [Line]
    public var lineWidth: CGFloat
    public var highlithedX: CGFloat?
    public var estimatedGridSpace: Int?
    public var estimatedXLabelWidth: Int?
    public var inset: CGFloat?
    public var isInFullSize: Bool
    public var range: Range?
    public var didHighlightX: ClosureWith<Output>?

    // Init
  }
}
```

In order to implement theming nicely `Colors` struct is used on each component too.

**ChartView.Colors example**

```
extension ChartView {

  public struct Colors {
    public let labels: UIColor
    public let horizontalLines: UIColor
    public let lineChart: LineChartLayer.Colors
    
    // Init
    
    public static let initial = Colors(
            labels: .gray,
            horizontalLines: .gray,
            lineChart: .initial)
  }
}
```

Each line of chart is represented by `Line` struct, where `Points` is typealias for `[CGPoint]`.

```
public struct Line {
  public let title: String
  public var points: Points
  public var highlightedPoint: CGPoint?
  public let color: UIColor
  public var isHidden: Bool

  // Init
}
```

### Views & Layers

- `ChartView` is a core view which is responsible for rendering all chart layers: 
![ChartView](https://i.ibb.co/SwVLZvF/Simulator-Screen-Shot-i-Phone-X-2019-03-25-at-13-02-41.png)
![Layer Hierarchy of `ChartView`](https://i.ibb.co/2MkdS2q/2019-03-25-12-56-28.jpg)
  - `GridLayer` renders horizontal lines of grid
  - `LineChartLayer` contains `LineLayer`s and `VerticalLineLayer`
    - LineLayer renders line based on `CGPoint` vector (if `VerticalLineLayer` is also appeared, it will also render circle in order to show highlighted point)
    - `VerticalLineLayer` renders vertical line through highlighted points
  - `YLabelsLayer` renders labels above horizontal lines of `GridLayer` (`y` values of each line)
  - `XLabelsLayer` renders labels below `LinearChartLayer` or `x` axis in a nutshell (dates in "MMM dd" format)
- `PannableChartView` is a subclass of `UIControl` which implements behaviour similar to `UIPanGestureRecognizer`. It tells `ChartView` to show highlighted points and shows `ChartInfoView` with details of the points above chart.
![PannableChartView](https://i.ibb.co/Y7XLk5k/Simulator-Screen-Shot-i-Phone-X-2019-03-25-at-13-18-09.png)
- `ChartScrollView` contains instance of `PannableChartView` and `ExpandableSliderView` which allows user to choose visible part of chart and its scale.
![ChartScrollView](https://i.ibb.co/s9jkSWq/Simulator-Screen-Shot-i-Phone-X-2019-03-25-at-13-18-13.png)
- `DetailedChartView` contains instance of `ChartScrollView` and `UITableView` with names and colors of lines and capability to show/hide them
![DetailedChartView](https://i.ibb.co/SfPqqhs/Simulator-Screen-Shot-i-Phone-X-2019-03-25-at-13-18-16.png)

### Normalizer

- `Normalizer` is a protocol which defines method for line normalization based on target rect size of layer.
- `SizeNormalizer` is a class which normalize lines based on:
  - [minY, maxY] segment with `verticalInses` (depends on `isInFullSize` and `verticalInset` properties)
  - [0, maxY] segment (full-sized)

**Note about minY, maxY:** 
- **Formal case:** minY, maxY are in {y | y in Y1 || Y2 || ... || Yn}, where `||` means union (set operation), Yi is a set of `y` values of the `i`th line 
- **Informal case:** minY, maxY are selected among each y of each line in chart


## License

iCharts is available under the MIT license. See the LICENSE file for more info.
