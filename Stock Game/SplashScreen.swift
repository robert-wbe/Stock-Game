//
//  SplashScreen.swift
//  Stock Game
//
//  Created by Robert Wiebe on 8/25/22.
//

import SwiftUI

struct SplashScreen: View {
    @Binding var isPresented: Bool
    var body: some View {
        VStack(){
            Spacer()
            Text("Welcome to The Wall Street Simulator!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Spacer()
            VStack(alignment: .leading, spacing: 75){
            
            HStack{
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundStyle(.green, .blue)
                Text("Simulate the Stock Market")
                    .font(.title.bold())
            }
            
            HStack{
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 50, weight: .regular))
                    .symbolRenderingMode(.multicolor)
                Text("Buy and sell shares")
                    .font(.title.bold())
            }
            
            HStack{
                Image(systemName: "banknote.fill")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundStyle(.secondary, .green)
                Text("And get rich!")
                    .font(.title.bold())
            }
            }
            
            Spacer()
            Text("Good Luck!")
            
            Button(action: {isPresented = false}){
                Text("Continue").frame(maxWidth: .infinity, maxHeight: 30)
            }.buttonStyle(.borderedProminent).padding(.horizontal, 35)
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}
