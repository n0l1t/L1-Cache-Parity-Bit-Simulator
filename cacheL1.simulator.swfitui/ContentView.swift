
import SwiftUI
import Charts

struct ErrorStat: Identifiable {
    let id = UUID()
    let type: String
    let count: Int
}

struct BitErrorStat: Identifiable {
    let id = UUID()
    let bitIndex: Int
    let count: Int
}

struct ContentView: View {

    
    @State private var stats: [ErrorStat] = []
    @State private var bitStats: [BitErrorStat] = []
    
    init(){
        
    }
    
    init(previewErrorType: ErrorType) {
        let iterations = 20_000
        let simulator = CacheSimulator(targetItetration: iterations)
        let noiseModel = NoiseModel(errorChance: 0.01, errorType: previewErrorType)
        let statistics = StatisticsCollector(32)

        simulator.simulate(nosieModel: noiseModel, stats: statistics)

        _stats = State(initialValue: [
            ErrorStat(type: "Обнаруженные", count: statistics.catchErrorCount),
            ErrorStat(type: "Необнаруженные", count: statistics.undetectedErrorCount)
        ])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text("L1 Cache Parity Bit Simulation")
                .font(.title)
                .bold()

            if stats.isEmpty {
                Text("Нажмите «Запустить симуляцию»")
                    .foregroundColor(.secondary)
            } else {

                Chart(stats) {
                    BarMark(
                        x: .value("Тип ошибки", $0.type),
                        y: .value("Количество", $0.count)
                    )
                }
                .frame(height: 250)

                if !bitStats.isEmpty {

                    Text("Распределение ошибок по битам")
                        .font(.headline)

                    Chart(bitStats) {
                        BarMark(
                            x: .value("Бит", $0.bitIndex),
                            y: .value("Количество ошибок", $0.count)
                        )
                    }
                    .frame(height: 200)
                }
            }

            Button("Запустить симуляцию") {
                runSimulation()
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
    }

    private func runSimulation() {
        let iterations = 50_000

        let simulator = CacheSimulator(targetItetration: iterations)
        let noiseModel = NoiseModel(errorChance: 0.01, errorType: .multiple)
        let statistics = StatisticsCollector(32)

        simulator.simulate(nosieModel: noiseModel, stats: statistics)
        
        bitStats = statistics.bitErrorHistogram.enumerated().map {
            BitErrorStat(bitIndex: $0.offset, count: $0.element)
        }

        stats = [
            ErrorStat(type: "Обнаруженные", count: statistics.catchErrorCount),
            ErrorStat(type: "Необнаруженные", count: statistics.undetectedErrorCount)
        ]
    }
}

#Preview("Solo errors") {
    ContentView(previewErrorType: .solo)
        .frame(width: 600, height: 650)
}

#Preview("Multiple errors") {
    ContentView(previewErrorType: .multiple)
        .frame(width: 600, height: 650)
}
