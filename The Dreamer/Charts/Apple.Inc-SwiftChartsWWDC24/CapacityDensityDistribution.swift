/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A chart that represents data in a histogram for for distribution of capacity density using `BarMark` and `LinePlot`.
*/

import SwiftUI
import Charts
import Accelerate

struct CapacityDensityDistribution: View {
    @Environment(Model.self) private var model: Model

    var body: some View {
        let capacityDensities = model.data
            .map { $0.capacityDC / Double($0.area) }
            .filter { $0 < 0.000_15 }

        let bins: [(index: Int, lowerBound: Double, upperBound: Double, probability: Double)] = {
            let bins = NumberBins(data: capacityDensities)
            let groups = Dictionary(grouping: capacityDensities,
                                    by: bins.index(for:))
            return groups.sorted(by: { $0.key < $1.key }).map {
                (index: $0.key, 
                 lowerBound: bins.lowerBound(for: $0.key),
                 upperBound: bins.upperBound(for: $0.key),
                 probability: Double($0.value.count) / Double(capacityDensities.count))
            }
        }()

        // Histogram that shows distribution of capacity density.

        Chart {
            let probabilityMax = bins.max(by: { $0.probability < $1.probability })?.probability ?? .nan
            let standardDeviation = vDSP.standardDeviation(capacityDensities)
            let mean = vDSP.mean(capacityDensities)
            let scale = probabilityMax / normalDistribution(mean, standardDeviation: standardDeviation, mean: mean)

            // MARK: Visualize area under a curve with AreaPlot

            AreaPlot(
                x: "Capacity density",
                y: "Probability"
            ) { @Sendable x in
                normalDistribution(x, standardDeviation: standardDeviation, mean: mean) * scale
            }
            .foregroundStyle(.gray)
            .opacity(0.5)

            // MARK: Visualize function with LinePlot

            LinePlot(
                x: "Capacity density",
                y: "Probability"
            ) { @Sendable x in
                normalDistribution(x, standardDeviation: standardDeviation, mean: mean) * scale
            }
            .foregroundStyle(.gray)

            // MARK: Histogram

            ForEach(bins, id: \.index) {
                BarMark(
                    x: .value("Capacity density", ($0.lowerBound + $0.upperBound) / 2),
                    y: .value("Probability", $0.probability),
                    width: .fixed($0.upperBound - $0.lowerBound)
                )
            }
        }
        .chartXAxisLabel("Capacity density (megawatts per m²)")
        .chartYAxisLabel("Probability")
    }
}

/// Probability function for normal distribution.
nonisolated private func normalDistribution(
    _ x: Double, standardDeviation: Double, mean: Double
) -> Double {
    exp(-pow((x - mean) / standardDeviation, 2) / 2)
         / (standardDeviation * sqrt(2 * .pi))
}

#Preview(traits: .sampleData) {
    CapacityDensityDistribution()
        .padding()
}
