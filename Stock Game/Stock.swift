//
//  Stock.swift
//  Stock Game
//
//  Created by Robert Wiebe on 8/19/22.
//

import Foundation

class Stock: ObservableObject, Identifiable{
    var id = UUID()
    @Published var value: Int
    @Published var name: String
    @Published var symbol: String
    @Published var riskClass: RiskClass
    @Published var history: [Int] = [Int](repeating: 500, count: 30)
    @Published var boughtShares: Int = 0
    @Published var sharesWorth: Int = 0
    @Published var isBankrupt: Bool = false
    var midChange: Double = 0
    var bigChange: Double = 0
    
    init(name: String, symbol:String, initialValue: Int, riskClass: RiskClass) {
        self.name = name
        self.symbol = symbol
        self.value = initialValue
        self.riskClass = riskClass
    }
    
    func updateValue(counter: Int){
        let lowerLimit: Double = self.value < 50 ? -0.5 : -1
        let change = pow(Double.random(in: lowerLimit...1.0), 3) * 50.0 * self.riskClass.growth
        if counter % self.riskClass.cycleTime == 0{
            self.midChange = pow(Double.random(in: lowerLimit...1.0), 3) * 15.0 * self.riskClass.growth
        }
        if counter % (6 * self.riskClass.cycleTime) == 0{
            self.bigChange = pow(Double.random(in: lowerLimit...1.0), 3) * 5.0 * self.riskClass.growth
        }
        self.value += Int((change + midChange + bigChange)*(Double(self.value)/500.0))
        if self.value < 0 {
            self.value = 0
            self.isBankrupt = true
        }
        self.objectWillChange.send()
        self.history.removeFirst()
        self.history.append(self.value)
    }
}

class StockManager: ObservableObject, Identifiable{
    var id = UUID()
    var updateCounter: Int = 0
    @Published var stocks: [Stock] = [
        Stock(name: "Apple Inc.", symbol: "AAPL", initialValue: 500, riskClass: .longTerm),
        Stock(name: "Alphabet Inc.", symbol: "GOOG", initialValue: 500, riskClass: .longTerm),
        Stock(name: "Tesla Inc.", symbol: "TSLA", initialValue: 500, riskClass: .riskyFisky),
        Stock(name: "Saudi Aramco", symbol: "2222.SR", initialValue: 500, riskClass: .safe),
        Stock(name: "Sinopec Group", symbol: "SPNC", initialValue: 500, riskClass: .safe)
    ]
    func update(){
        for stock in self.stocks{
            if !stock.isBankrupt{
                stock.updateValue(counter: updateCounter)
                self.objectWillChange.send()
            }
        }
        self.updateCounter += 1
    }
}

enum RiskClass {
    case riskyFisky
    case longTerm
    case safe
    
    var growth: Double {
        switch self {
        case .riskyFisky:
            return 1.5
        case .longTerm:
            return 1
        case .safe:
            return 0.75
        }
    }
    
    var cycleTime: Int {
        switch self {
        case .riskyFisky:
            return 5
        case .longTerm:
            return 15
        case .safe:
            return 10
        }
    }
}
