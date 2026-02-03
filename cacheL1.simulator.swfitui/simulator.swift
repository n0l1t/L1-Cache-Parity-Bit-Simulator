import Foundation

enum ErrorType{
    case solo
    case multiple
}

struct ParityBit{
    static func calculate(from data: [Int]) -> Int{
        data.reduce(0, +) % 2
    }
    static func check(data: [Int], parity: Int) -> Bool{
        calculate(from: data) == parity
    }
}

class CacheLine{
    var dataArray: [Int]
    let lineLength: Int
    
    init(_ lineLength: Int) {
        var data: [Int] = Array(repeating: 0, count:lineLength)
        for i in 0..<lineLength{
            data[i] = Int.random(in: 0...1)
        }
        self.dataArray = data
        self.lineLength = lineLength
    }
}


class StatisticsCollector {
    var undetectedErrorCount = 0
    var catchErrorCount = 0
    var withoutError = 0
    var bitErrorHistogram: [Int]
    
    init(_ lineLength: Int) {
        self.bitErrorHistogram = Array(repeating: 0, count: lineLength)
    }
    
    func printReport() {
        print("Необнаруженные ошибки: \(undetectedErrorCount)")
        print("Обнаружено с битом чётности: \(catchErrorCount)")
        print("Без ошибок: \(withoutError)")
    }
}

class NoiseModel{
    let errorChance : Double
    let errorType: ErrorType
    
    init(errorChance: Double, errorType: ErrorType) {
        self.errorChance = errorChance
        self.errorType = errorType
    }
    
    func generateError(to line: CacheLine) -> Int?{
        let randomValue = Double.random(in: 0.0...1.0)
        guard randomValue <= errorChance else { return nil }
        
        if errorType == .solo {
            let randomIndex = Int.random(in: 0..<line.lineLength)
            line.dataArray[randomIndex] ^= 1
            return randomIndex
        }else{
            var corrutedIndices: [Int] = []
            for i in 0..<line.lineLength{
                let bitRandom = Double.random(in: 0.0...1.0)
                if bitRandom <= errorChance{
                    line.dataArray[i] ^= 1
                    corrutedIndices.append(i)
                }
            }
            return corrutedIndices.isEmpty ? nil : corrutedIndices.first
        }
    }
}

class CacheSimulator{
    var targetItetration: Int
    
    init(targetItetration: Int) {
        self.targetItetration = targetItetration
    }
    var bitErrorHist = StatisticsCollector(32)
    func simulate(nosieModel : NoiseModel , stats: StatisticsCollector){
        for _ in 0..<targetItetration{
            let line = CacheLine(32)
            let originalData = line.dataArray
            let originalParity = ParityBit.calculate(from: originalData)
            
            let errorIndex = nosieModel.generateError(to: line)
            
            if errorIndex != nil{
                let newParity = ParityBit.calculate(from: line.dataArray)
                if newParity != originalParity{
                    stats.catchErrorCount += 1
                }else{
                    stats.undetectedErrorCount += 1
                }
            }else{
                stats.withoutError += 1
            }
            if let corruptedIndex = errorIndex {
                stats.bitErrorHistogram[corruptedIndex] += 1
            }
        }
    }
}
