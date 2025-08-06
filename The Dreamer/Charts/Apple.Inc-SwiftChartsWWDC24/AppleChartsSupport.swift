//
//  AppleChartsSupport.swift
//  The Dreamer
//
//  Created by AI Assistant
//  适配Apple.Inc-SwiftChartsWWDC24示例代码的支持文件
//

import SwiftUI
import Charts
import Foundation

// MARK: - 数据模型适配

/// Apple示例代码使用的数据点模型
struct DataPoint: Identifiable {
    let id = UUID()
    let startYear: Int
    let capacityGW: Double
    let capacityDensity: Double
    let capacityDC: Double      // Heatmap使用的属性
    let area: Int               // CapacityDensityDistribution使用的属性
    let facilityCount: Double   // TimeSeriesPanel使用的属性
    let xLongitude: Coordinate
    let yLatitude: Coordinate
    
    // ThematicMapPanel使用的属性
    var mapProjection: Coordinate {
        Coordinate(degrees: xLongitude.degrees, y: yLatitude.degrees)
    }
    let technology: String
    let region: String
    let state: String
    let name: String  // ThematicMapPanel使用的属性
    
    // BreakdownHistogram使用的属性
    var panelAxisType: String { technology }
    var tech: String { technology }
    
    // 动态属性访问支持
    subscript(keyPath: KeyPath<DataPoint, String>) -> String {
        self[keyPath: keyPath]
    }
}

/// 坐标结构
struct Coordinate {
    let degrees: Double
    let y: Double
    
    init(degrees: Double, y: Double = 0) {
        self.degrees = degrees
        self.y = y
    }
    
    var x: Double { degrees }
}

/// 美国本土边界坐标
let contiguousUSABorderCoordinates: [Coordinate] = [
    Coordinate(degrees: -125, y: 25),
    Coordinate(degrees: -125, y: 50),
    Coordinate(degrees: -68, y: 50),
    Coordinate(degrees: -68, y: 25),
    Coordinate(degrees: -125, y: 25)
]

/// 分类枚举
enum BreakdownCategory: String, CaseIterable, Identifiable {
    case axisType = "Axis Type"
    case technology = "Technology"
    case state = "State"
    
    var id: String { rawValue }
    
    var description: String { rawValue }
    
    var keyPath: KeyPath<DataPoint, String> {
        switch self {
        case .axisType: \.panelAxisType
        case .technology: \.tech
        case .state: \.state
        }
    }
    
    var domain: [String] {
        switch self {
        case .axisType: ["Horizontal", "Vertical", "Tilted"]
        case .technology: ["Solar", "Wind", "Hydro", "Nuclear"]
        case .state: ["CA", "TX", "NY", "FL", "WA"]
        }
    }
}

/// Apple示例代码使用的主要模型
@Observable
class Model {
    var data: [DataPoint] = []
    var filteredData: [DataPoint] { data }
    var breakdownField: BreakdownCategory = .technology
    var hoveredYear: Int?
    var hoveredTime: Date?
    
    init() {
        // 生成示例数据
        generateSampleData()
    }
    
    private func generateSampleData() {
        let technologies = ["Solar", "Wind", "Hydro", "Nuclear"]
        let states = ["CA", "TX", "NY", "FL", "WA"]
        
        var facilityIndex = 0
        for year in 2015...2024 {
            for _ in 0..<10 {
                facilityIndex += 1
                let dataPoint = DataPoint(
                    startYear: year,
                    capacityGW: Double.random(in: 10...100),
                    capacityDensity: Double.random(in: 20...180),
                    capacityDC: Double.random(in: 5...50),
                    area: Int.random(in: 100...1000),
                    facilityCount: Double.random(in: 1...20),
                    xLongitude: Coordinate(degrees: Double.random(in: -125...(-68)), y: 0),
                    yLatitude: Coordinate(degrees: Double.random(in: 25...50), y: Double.random(in: 25...50)),
                    technology: technologies.randomElement()!,
                    region: "Region", // 保持兼容性
                    state: states.randomElement()!,
                    name: "Facility \(facilityIndex)" // ThematicMapPanel使用的属性
                )
                data.append(dataPoint)
            }
        }
    }
}

// MARK: - 数据分箱支持

/// 图表分箱范围
typealias ChartBinRange<T: Comparable> = ClosedRange<T>

/// 数值分箱工具
struct NumberBins {
    let thresholds: [Double]
    
    init(thresholds: [Double]) {
        self.thresholds = thresholds.sorted()
    }
    
    init(data: [Double], binCount: Int = 20) {
        guard !data.isEmpty else {
            self.thresholds = []
            return
        }
        
        let sortedData = data.sorted()
        let min = sortedData.first!
        let max = sortedData.last!
        let range = max - min
        
        if range == 0 {
            self.thresholds = [min, max]
        } else {
            let step = range / Double(binCount)
            self.thresholds = (0...binCount).map { min + Double($0) * step }
        }
    }
    
    func index(for value: Double) -> Int {
        // 找到值应该放在哪个分箱中
        for (index, threshold) in thresholds.enumerated() {
            if value <= threshold {
                return max(0, index - 1)
            }
        }
        return max(0, thresholds.count - 2)
    }
    
    subscript(index: Int) -> ChartBinRange<Double> {
        guard index >= 0 && index < thresholds.count - 1 else {
            return 0...0
        }
        return thresholds[index]...thresholds[index + 1]
    }
    
    func lowerBound(for index: Int) -> Double {
        guard index >= 0 && index < thresholds.count - 1 else { return 0 }
        return thresholds[index]
    }
    
    func upperBound(for index: Int) -> Double {
        guard index >= 0 && index < thresholds.count - 1 else { return 0 }
        return thresholds[index + 1]
    }
}

// MARK: - 数学函数支持

/// 二次回归
struct QuadraticRegression {
    private let a: Double
    private let b: Double
    private let c: Double
    
    init<T>(_ data: [T], x xKeyPath: KeyPath<T, Double>, y yKeyPath: KeyPath<T, Double>) {
        // 简化的二次回归实现
        let xValues = data.map { $0[keyPath: xKeyPath] }
        let yValues = data.map { $0[keyPath: yKeyPath] }
        
        // 使用最小二乘法的简化版本
        let n = Double(data.count)
        let sumX = xValues.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map(*).reduce(0, +)
        let sumX2 = xValues.map { $0 * $0 }.reduce(0, +)
        
        // 简化为线性回归
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        self.a = 0 // 二次项系数设为0，简化为线性
        self.b = slope
        self.c = intercept
    }
    
    nonisolated func callAsFunction(_ x: Double) -> Double {
        return a * x * x + b * x + c
    }
}

/// 置信区间
struct ConfidenceInterval {
    private let regression: QuadraticRegression
    private let margin: Double
    
    init<T>(data: [T], x xKeyPath: KeyPath<T, Double>, y yKeyPath: KeyPath<T, Double>, regression: QuadraticRegression) {
        self.regression = regression
        self.margin = 10.0 // 简化的置信区间
    }
    
    nonisolated func callAsFunction(_ x: Double) -> (low: Double, high: Double) {
        let predicted = regression(x)
        return (low: predicted - margin, high: predicted + margin)
    }
}

// MARK: - 时间工具函数

/// 从年份创建日期
func dateFromYear(_ year: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: year)) ?? Date()
}

/// 时间域
var timeDomain: ClosedRange<Date> {
    dateFromYear(2015)...dateFromYear(2024)
}

// MARK: - 预览特性扩展

extension PreviewTrait where T == Preview.ViewTraits {
    /// 示例数据预览特性
    static var sampleData: PreviewTrait<T> {
        .modifier(SampleDataModifier())
    }
}

/// 示例数据修饰器
struct SampleDataModifier: PreviewModifier {
    static func makeSharedContext() async throws -> Model {
        Model()
    }
    
    func body(content: Content, context: Model) -> some View {
        content
            .environment(context)
    }
}

// MARK: - 函数示例类型

/// 函数示例枚举
enum FunctionExample: Identifiable {
    case linePlot(y: String, function: @Sendable (Double) -> Double, xDomain: ClosedRange<Double> = -5...5, yDomain: ClosedRange<Double> = -5...5)
    case areaPlot(y: String, function: @Sendable (Double) -> Double, xDomain: ClosedRange<Double> = -5...5, yDomain: ClosedRange<Double> = -5...5)
    case areaPlotBetween(yStart: String, yEnd: String, function: @Sendable (Double) -> (yStart: Double, yEnd: Double), xDomain: ClosedRange<Double> = -5...5, yDomain: ClosedRange<Double> = -5...5)
    case parametricLinePlot(description: String, x: String, y: String, tDomain: ClosedRange<Double>, function: @Sendable (Double) -> (x: Double, y: Double), xDomain: ClosedRange<Double> = -5...5, yDomain: ClosedRange<Double> = -5...5)
    
    var id: String {
        switch self {
        case .linePlot(let y, _, _, _): return "Line: \(y)"
        case .areaPlot(let y, _, _, _): return "Area: \(y)"
        case .areaPlotBetween(let yStart, let yEnd, _, _, _): return "Area Between: \(yStart) and \(yEnd)"
        case .parametricLinePlot(let description, _, _, _, _, _, _): return description
        }
    }
    
    var xDomain: ClosedRange<Double> {
        switch self {
        case .linePlot(_, _, let xDomain, _): return xDomain
        case .areaPlot(_, _, let xDomain, _): return xDomain
        case .areaPlotBetween(_, _, _, let xDomain, _): return xDomain
        case .parametricLinePlot(_, _, _, _, _, let xDomain, _): return xDomain
        }
    }
    
    var yDomain: ClosedRange<Double> {
        switch self {
        case .linePlot(_, _, _, let yDomain): return yDomain
        case .areaPlot(_, _, _, let yDomain): return yDomain
        case .areaPlotBetween(_, _, _, _, let yDomain): return yDomain
        case .parametricLinePlot(_, _, _, _, _, _, let yDomain): return yDomain
        }
    }
}

// MARK: - 常量定义

/// 仪表板内边距
let dashboardPadding: CGFloat = 16

/// 年份范围
let startYear: Int = 2015
let endYear: Int = 2024

// MARK: - 面板样式扩展

extension View {
    /// 简化的图表面板样式（避免与DashboardPanel冲突）
    func chartPanel(darker: Bool = false) -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(darker ? Color.gray.opacity(0.1) : Color.white)
                    .shadow(radius: 2)
            )
    }
}