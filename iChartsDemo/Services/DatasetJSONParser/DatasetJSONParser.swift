//
//  DatasetJSONParser.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation
import CoreGraphics
import Utils

final class DatasetJSONParser {
    typealias Completion = (Result<[Dataset]>) -> Void
    
    private typealias RawDataset = [String: Any]
    
    private let workQueue = DispatchQueue(label: "dataset-json-parser", qos: .userInitiated)
    
    func parse(from filePath: String, completion: @escaping Completion) throws {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let datasets = try self.parse(from: filePath)
                completion(.success(datasets))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func parse(from filePath: String) throws -> [Dataset] {
        let data = try self.data(from: filePath)

        guard let rawDatasets = try JSONSerialization.jsonObject(with: data, options: []) as? [RawDataset] else {
            throw Error.other(message: "Can not parse json from data")
        }
        
        return try parseDatasets(from: rawDatasets)
    }
    
    private func data(from filePath: String) throws -> Data {
        let url = URL(fileURLWithPath: filePath)
        return try Data(contentsOf: url)
    }
    
    private func parseDatasets(from datasets: [RawDataset]) throws -> [Dataset] {
        return try datasets.map(parseDataset(from:))
    }
    
    private func parseDataset(from dataset: RawDataset) throws -> Dataset {
        let vectors = try parseVectors(from: dataset)
        let xs = try parseAbscissa(with: vectors, from: dataset)
        let charts = try parseCharts(with: vectors, from: dataset, abscissaLabel: xs.label)
        
        return Dataset(xs: xs, charts: charts)
    }
    
    
    // MARK: - ParseVectors
    
    private func parseVectors(from dataset: RawDataset) throws -> [Dataset.Vector] {
        let columns: [Any] = try value(for: "columns", in: dataset)
        return try columns.map(parseVector(from:))
    }
    
    private func value<T>(for key: String, in container: Any) throws -> T {
        let dataset: RawDataset = try cast(container, name: "Container")
        
        guard let value = dataset[key] else {
            throw Error.valueIsNotExisted(at: key)
        }
        
        return try cast(value, name: key)
    }
    
    private func cast<T>(_ value: Any, name: String) throws -> T {
        guard let typedValue = value as? T else {
            throw Error.canNotCastValue(at: name, to: T.self)
        }
        
        return typedValue
    }
    
    private func parseVector(from column: Any) throws -> Dataset.Vector {
        var column: [Any] = try cast(column, name: "Column")
        
        guard !column.isEmpty else {
            throw Error.other(message: "Column list is empty")
        }
        
        let label: String = try cast(column.remove(at: 0), name: "The first item of column list")
        
        guard !column.isEmpty else {
            throw Error.collection("Column", doesNotContain: "any points")
        }
        
        let dots: [CGFloat] = try cast(column, name: "All elements except the first one in column")
        
        return Dataset.Vector(label: label, dots: dots)
    }
    
    
    // MARK: - Parse abscissa
    
    private func parseAbscissa(with vectors: [Dataset.Vector], from dataset: RawDataset) throws -> Dataset.Vector {
        let kinds: [String: String] = try value(for: "types", in: dataset)
        
        guard let label = kinds.first(where: { $0.value == "x" })?.key else {
            throw Error.collection("types", doesNotContain: "\"x\" type")
        }
        
        guard let vector = vectors.first(where: { $0.label == label }) else {
            throw Error.collection("columns", doesNotContain: "column with label \(label)")
        }
        
        return vector
    }
    
    // MARK: - Parse chart
    
    private func parseCharts(with vectors: [Dataset.Vector],
                             from dataset: RawDataset,
                             abscissaLabel: String) throws -> [Dataset.Chart] {
        
        return try vectors.compactMap { vector in
            do {
                return try parseChart(with: vector, dataset: dataset, abscissaLabel: abscissaLabel)
            } catch Error.isAbcsissa {
                return nil
            }
        }
    }
    
    private func parseChart(with vector: Dataset.Vector,
                            dataset: RawDataset,
                            abscissaLabel: String) throws -> Dataset.Chart {
        
        let label = vector.label
        
        guard label != abscissaLabel else {
            throw Error.isAbcsissa
        }
        
        let name: String = try parseValue(for: label, key: "names", from: dataset)
        let color: String = try parseValue(for: label, key: "colors", from: dataset)
        let kind = try parseKind(for: label, from: dataset)
        
        return Dataset.Chart(name: name, vector: vector, color: color, kind: kind)
    }
    
    private func parseKind(for label: String, from dataset: RawDataset) throws -> Dataset.Chart.Kind {
        let kindString: String = try parseValue(for: label, key: "types", from: dataset)
        
        guard kindString != "x" else {
            throw Error.isAbcsissa
        }
        
        guard let kind = Dataset.Chart.Kind(rawValue: kindString) else {
            throw Error.other(message: "Kind with \(kindString) raw valus doesn't exist.")
        }
        
        return kind
    }
    
    private func parseValue<T>(for label: String, key: String, from dataset: RawDataset) throws -> T {
        let kinds: RawDataset = try value(for: key, in: dataset)
        return try value(for: label, in: kinds)
    }
}

extension DatasetJSONParser {
    
    enum Error: Swift.Error {
        case valueIsNotExisted(at: String)
        case canNotCastValue(at: String, to: Any.Type)
        case collection(String, doesNotContain: String)
        case other(message: String)
        case isAbcsissa
    }
}
