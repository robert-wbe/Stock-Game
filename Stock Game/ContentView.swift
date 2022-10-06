//
//  ContentView.swift
//  Stock Game
//
//  Created by Robert Wiebe on 8/19/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var stockManager: StockManager = .init()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var selectedStockIndex = 0
    @State var money: Int = 2000
    @State var cashFlow: CashFlow = .steady
    @AppStorage("splashscreen") var splashScreen: Bool = true
    var body: some View {
        VStack {
            VStack{
                ScrollView(.horizontal){
                    HStack(spacing: 15){
                        Spacer()
                            .frame(width: 0)
                        Image(systemName: "gift")
                            .font(.largeTitle)
                            .frame(width: 75, height: 125)
                            .background(Color.primary.opacity(0.2))
                            .cornerRadius(15)
                        Image(systemName: "newspaper")
                            .font(.largeTitle)
                            .frame(width: 75, height: 125)
                            .background(Color.primary.opacity(0.2))
                            .cornerRadius(15)
                        ForEach(Array(zip(stockManager.stocks.indices, stockManager.stocks)), id: \.0){ i, stock in
                            Button(action: {self.selectedStockIndex = i}) {
                                SmallStockView(stock: stock)
                            }.buttonStyle(ScaleButtonStyle())
                        }
                    }
                }.frame(height: 125)
                    .frame(maxWidth: .infinity)
                StockFocusView(stock: stockManager.stocks[selectedStockIndex])
                .onReceive(timer, perform: {time in
                    stockManager.update()
                })
                if !stockManager.stocks[selectedStockIndex].isBankrupt {
                    HStack{
                        VStack{
                            Button(action:{
                                stockManager.stocks[selectedStockIndex].boughtShares += 1
                                money -= stockManager.stocks[selectedStockIndex].value
                                cashFlow = .down
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {cashFlow = .steady})
                                stockManager.stocks[selectedStockIndex].sharesWorth += stockManager.stocks[selectedStockIndex].value
                            }) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                    Label("Buy 1", systemImage: "square.and.arrow.down")
                                        .colorInvert()
                                }
                            }.buttonStyle(ScaleButtonStyle()).disabled(money < stockManager.stocks[selectedStockIndex].value)
                                .opacity(money < stockManager.stocks[selectedStockIndex].value ? 0.8 : 1)
                            Button(action:{
                                stockManager.stocks[selectedStockIndex].boughtShares += 3
                                money -= 3*stockManager.stocks[selectedStockIndex].value
                                cashFlow = .down
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {cashFlow = .steady})
                                stockManager.stocks[selectedStockIndex].sharesWorth += 3*stockManager.stocks[selectedStockIndex].value
                            }) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                    Label("Buy 3", systemImage: "square.and.arrow.down")
                                        .colorInvert()
                                }
                            }.buttonStyle(ScaleButtonStyle()).disabled(money < 3*stockManager.stocks[selectedStockIndex].value)
                                .opacity(money < 3*stockManager.stocks[selectedStockIndex].value ? 0.8 : 1)
                            Button(action:{
                                while money >= stockManager.stocks[selectedStockIndex].value {
                                    stockManager.stocks[selectedStockIndex].boughtShares += 1
                                    money -= stockManager.stocks[selectedStockIndex].value
                                    stockManager.stocks[selectedStockIndex].sharesWorth += stockManager.stocks[selectedStockIndex].value
                                }
                                cashFlow = .down
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {cashFlow = .steady})
                            }) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                    Label("All In", systemImage: "square.and.arrow.down")
                                        .font(.body.bold())
                                        .colorInvert()
                                }
                            }.buttonStyle(ScaleButtonStyle()).disabled(money < stockManager.stocks[selectedStockIndex].value)
                                .opacity(money < stockManager.stocks[selectedStockIndex].value ? 0.8 : 1)
                        }
                        VStack{
                            Button(action:{
                                stockManager.stocks[selectedStockIndex].sharesWorth -= stockManager.stocks[selectedStockIndex].sharesWorth/stockManager.stocks[selectedStockIndex].boughtShares
                                stockManager.stocks[selectedStockIndex].boughtShares -= 1
                                money += stockManager.stocks[selectedStockIndex].value
                                cashFlow = .up
                                playSound(sound: "ka-ching", type: "mp3")
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {cashFlow = .steady})
                            }) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                    Label("Sell 1", systemImage: "square.and.arrow.up")
                                        .colorInvert()
                                }
                            }.buttonStyle(ScaleButtonStyle()).disabled(stockManager.stocks[selectedStockIndex].boughtShares == 0)
                                .opacity(stockManager.stocks[selectedStockIndex].boughtShares == 0 ? 0.8 : 1)
                            Button(action:{
                                stockManager.stocks[selectedStockIndex].sharesWorth -= 3*stockManager.stocks[selectedStockIndex].sharesWorth/stockManager.stocks[selectedStockIndex].boughtShares
                                stockManager.stocks[selectedStockIndex].boughtShares -= 3
                                money += 3*stockManager.stocks[selectedStockIndex].value
                                cashFlow = .up
                                playSound(sound: "ka-ching", type: "mp3")
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {cashFlow = .steady})
                                
                            }) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                    Label("Sell 3", systemImage: "square.and.arrow.up")
                                        .colorInvert()
                                }
                            }.buttonStyle(ScaleButtonStyle()).disabled(stockManager.stocks[selectedStockIndex].boughtShares <= 2)
                                .opacity(stockManager.stocks[selectedStockIndex].boughtShares <= 2 ? 0.8 : 1)
                            Button(action:{
                                money += stockManager.stocks[selectedStockIndex].boughtShares * stockManager.stocks[selectedStockIndex].value
                                stockManager.stocks[selectedStockIndex].boughtShares = 0
                                stockManager.stocks[selectedStockIndex].sharesWorth = 0
                                cashFlow = .up
                                playSound(sound: "ka-ching", type: "mp3")
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {cashFlow = .steady})
                            }) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                    Label("Sell All", systemImage: "square.and.arrow.up")
                                        .font(.body.bold())
                                        .colorInvert()
                                }
                            }.buttonStyle(ScaleButtonStyle()).disabled(stockManager.stocks[selectedStockIndex].boughtShares == 0)
                                .opacity(stockManager.stocks[selectedStockIndex].boughtShares == 0 ? 0.8 : 1)
                        }
                    }.frame(height: 130)
                        .padding(5)
                } else {
                    VStack{
                        Image(systemName: "xmark.octagon")
                            .font(.system(size: 50, weight: .regular))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.red)
                        Text("Company Bankrupt")
                            .font(.title2.bold())
                        Text("Due to the bankruptcy of \(stockManager.stocks[selectedStockIndex].name) ,\nall stock was lost.")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            
                    }.frame(height: 130)
                }
                HStack{
                    Image(systemName: cashFlow.symbol)
                    Text("Cash: $\(money).00")
                }
                    .font(.title.bold())
                    .foregroundColor(cashFlow.color)
                    .animation(.easeInOut(duration: cashFlow != .steady ? 0.0 : 1.0), value: cashFlow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
            }
        }.sheet(isPresented: $splashScreen){
            SplashScreen(isPresented: $splashScreen)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.portrait)
    }
}

struct StockChart: View {
    @ObservedObject var stock: Stock
//    @State var referencePrice: Int? = 500
    var showLines: Bool
    var upperLimit: Int
    var body: some View{
            Canvas { context, size in
                if showLines {
                context.stroke(Path{path in
                    for i in 1..<10{
                        path.move(to: .init(x: 0, y: i*Int(size.height)/10))
                        path.addLine(to: .init(x: size.width, y: CGFloat(i)*size.height/10))
                        context.draw(Text("$\(upperLimit-i*(upperLimit/10))").bold(), at: .init(x: size.width-30, y: CGFloat(i)*size.height/10-10))
                    }
                }, with: .color(.gray.opacity(0.5)))
                }

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: -10, y: size.height/2))
                        for (i, price) in self.stock.history.enumerated(){
                            path.addLine(to: CGPoint(x: CGFloat(i)*size.width/CGFloat(29), y: size.height-CGFloat(price)*size.height/CGFloat(upperLimit)))
                        }
                    }, with: .color(stock.boughtShares > 0 ? (stock.value < (stock.sharesWorth/stock.boughtShares) ? .red : .green) : .primary), lineWidth: 3
                )
                context.fill(
                    Path { path in
                        path.move(to: CGPoint(x: -10, y: size.height/2))
                        for (i, price) in self.stock.history.enumerated(){
                            path.addLine(to: CGPoint(x: CGFloat(i)*size.width/CGFloat(29), y: size.height-CGFloat(price)*size.height/CGFloat(upperLimit)))
                        }
                        path.addLine(to: CGPoint(x: size.width+10, y: size.height+10))
                        path.addLine(to: CGPoint(x: -10, y: size.height+10))
                    }, with: .linearGradient(.init(colors: stock.boughtShares > 0 ? (stock.value < (stock.sharesWorth/stock.boughtShares) ? [.red, .red.opacity(0)] : [.green, .green.opacity(0)]) : [.primary, .primary.opacity(0)]), startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: size.height))
                )
                if stock.boughtShares > 0 {
                    context.stroke(
                        Path{ path in
                            path.move(to: CGPoint(x: 0, y: Int(size.height)-(stock.sharesWorth/stock.boughtShares)*Int(size.height)/upperLimit))
                            path.addLine(to: CGPoint(x: size.width, y: CGFloat(Int(size.height)-(stock.sharesWorth/stock.boughtShares)*Int(size.height)/upperLimit)))
                        } ,with: .color(.white), style: .init(lineWidth: 2, dash: [5, 5]))
                }
                            }
    }
}

struct StockFocusView: View {
    @ObservedObject var stock: Stock
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stock.symbol)
                Text("•")
                Text(String("$\(stock.value).00"))
                    .foregroundColor(stock.boughtShares > 0 ? (stock.value < (stock.sharesWorth/stock.boughtShares) ? .red : .green) : .primary)
            }.font(.largeTitle.bold())
                .padding(.leading)
            Text(stock.name)
                .padding(.leading)
            StockChart(stock: stock, showLines: true, upperLimit: 1000 + stock.value - stock.value % 1000)
        }
    }
}

struct SmallStockView: View {
    @ObservedObject var stock: Stock
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.primary.opacity(0.2)
            StockChart(stock: stock, showLines: false, upperLimit: 1000 + stock.value - stock.value % 1000)
            VStack(alignment: .leading) {
                HStack {
                    Text(stock.symbol)
                        .bold()
                        .strikethrough(stock.isBankrupt)
                    if stock.boughtShares > 0{
                        Text("• \(stock.boughtShares) owned")
                            .font(.caption)
                    }
                        
                }.foregroundColor(.primary)
                if stock.isBankrupt{
                    Text("bankrupt")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }.padding([.top, .leading])
        }
        .frame(width: 150, height: 125)
        .cornerRadius(15)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

enum CashFlow {
    case up
    case steady
    case down
    
    var symbol: String {
        switch self {
        case .up:
            return "arrow.up.circle"
        case .steady:
            return "dollarsign.circle"
        case .down:
            return "arrow.down.circle"
        }
    }
    var color: Color {
        switch self {
        case .up:
            return .green
        case .steady:
            return .primary
        case .down:
            return .red
        }
    }
}
