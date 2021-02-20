//
//  ListView.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import SwiftUI
import RHLinePlot

struct ListView: View {
    var color: Color
    var symbol: String
    var company: String
    var chart: String
    var price: String
    var edit: Bool?
    var id : UUID?
    var coreStocks = ObserverCoreData.shared
    var body: some View {
        NavigationLink(destination: RHChartView(symbol: symbol)) {
            ZStack {
                HStack {
                    if edit != nil && edit! {
                        Button(action: {
                            if self.id != nil {
                                self.coreStocks.delete(id: self.id!)
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .resizable()
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                .foregroundColor(.red)
                                .background(Circle().foregroundColor(.white))
                                .frame(width: 15, height: 15)
                        }.foregroundColor(.red)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(symbol)
                            .font(Font.custom("CapsuleSansText", size: 15))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        Text(company)
                            .font(Font.custom("CapsuleSansText", size: 13))
                            .foregroundColor(.black)
                            .opacity(0.5)
                    }.frame(width: 150, alignment: Alignment(horizontal: .leading, vertical: .center))
                    Spacer()
                    Image(uiImage: UIImage(named: chart)!)
                        .resizable()
                        .frame(width: 50, height: 30)
                    Spacer()
                    Text("$\(price)")
                        .font(Font.custom("CapsuleSansText", size: 17))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(RoundedRectangle(cornerRadius: 6).fill(color))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        //.padding(.trailing, 22)
                }
                
            }.padding()
            .frame(height: 60)
            .animation(.spring())
        }
        
        
    }
}

//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView(color: Color.green, symbol: "APPL", company: "Uber Technologies Inc", chart: Image(systemName: "forward.fill"), price: "$123.45")
//    }
//}
