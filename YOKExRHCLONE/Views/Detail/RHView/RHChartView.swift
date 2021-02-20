//
//  RHChartView.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Combine
import SwiftUI
import RHLinePlot

struct RHChartView: View {
    var symbol: String//"TSLA"
    typealias PlotData = RHChartViewModel.PlotData
    
    @State var timeDisplayMode: TimeDisplayOption = .hourly
    @State var isLaserModeOn = false
    @State var currentIndex: Int? = nil
    @ObservedObject var viewModel: RHChartViewModel
    let provider : Provider = Provider.finnhub
    @State var stockPriceChange: String = "hello"
    @State var stockPercentChange: String = ""
    @State var stockName: String = ""
    
    init(symbol: String) {
        self.symbol = symbol
        self.viewModel = RHChartViewModel(symbol: self.symbol)
    }
    
    
    var currentPlotData: PlotData? {
        switch timeDisplayMode {
        case .hourly:
            return viewModel.intradayPlotData
        case .daily:
            return viewModel.dailyPlotData
        case .weekly:
            return viewModel.weeklyPlotData
        case .monthly:
            return viewModel.monthlyPlotData
        }
    }
    
    var plotDataSegments: [Int]? {
        guard let currentPlotData = currentPlotData else { return nil }
        switch timeDisplayMode {
        case .hourly:
            return RHChartViewModel.segmentByHours(values: currentPlotData)
        case .daily:
            return RHChartViewModel.segmentByMonths(values: currentPlotData)
        case .weekly, .monthly:
            return RHChartViewModel.segmentByYears(values: currentPlotData)
        }
    }
    
    var plotRelativeWidth: CGFloat {
        switch timeDisplayMode {
        case .hourly:
            return 0.7 // simulate today's data
        default:
            return 1.0
        }
    }
    
    var showGlowingIndicator: Bool {
        switch timeDisplayMode {
        case .hourly:
            return true // simulate today's data
        default:
            return false
        }
    }
    
    // MARK: Body
    func readyPageContent(plotData: PlotData) -> some View {
        let firstPrice = plotData.first?.price ?? 0
        let lastPrice = plotData.last?.price ?? 0
        let themeColor = firstPrice <= lastPrice ? rhThemeColor : rhRedThemeColor
        return ScrollView {
            stockHeaderAndPrice(plotData: plotData)
            HStack {
                Image(systemName: stockPercentChange.contains("-") ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                    .foregroundColor(stockPriceChange.contains("-") ? Color.red : Color.green)
                Text(self.stockPriceChange)
                    .font(Font.custom("CapsuleSansText", size: 20))
                    .foregroundColor(stockPriceChange.contains("-") ? Color.red : Color.green)
                Text("(\(self.stockPercentChange))")
                    .font(Font.custom("CapsuleSansText", size: 20))
                    .foregroundColor(stockPriceChange.contains("-") ? Color.red : Color.green)
                Spacer()
            }.padding(.horizontal)
            plotBody(plotData: plotData)
            TimeDisplayModeSelector(
                currentTimeDisplayOption: $timeDisplayMode,
                eligibleModes: TimeDisplayOption.allCases
            ).accentColor(themeColor)
            
            Divider()
            HStack {
                Text("All Segments")
                    .bold()
                    .rhFont(style: .title2)
                Spacer()
            }.padding([.leading, .top], 22)
            rowsOfSegment(plotData)
            Spacer()
        }
    }
    
    func rowsOfSegment(_ plotData: PlotData) -> some View {
        guard let segments = viewModel.segmentsDataCache[timeDisplayMode] else {
            return AnyView(EmptyView())
        }
        let allSplitPoints = segments + [plotData.count]
        let fromAndTos = Array(zip(allSplitPoints, allSplitPoints[1...]))
        let allTimes = plotData.map { $0.time }
        let allValues = plotData.map { $0.price }
        let dateFormatter = timeDisplayMode == .hourly ?
            SharedDateFormatter.onlyTime : SharedDateFormatter.dayAndYear
        return AnyView(ForEach((0..<fromAndTos.count).reversed(), id: \.self) { (i) -> AnyView in
            let (from, to) = fromAndTos[i]
            let endingPrice = allValues[to-1]
            let firstPrice = allValues[from]
            let endingTime = allTimes[to-1]
            let color = endingPrice >= firstPrice ? rhThemeColor : rhRedThemeColor
            return AnyView(self.segmentRow(
                titleText: "\(dateFormatter.string(from: endingTime))",
                values: Array(allValues[from..<to]),
                priceText: "$\(endingPrice.round2Str())").accentColor(color)
            )
            }.drawingGroup())
    }
    func segmentRow(titleText: String, values: [CGFloat], priceText: String) -> some View {
        HStack {
            Text(titleText)
                .rhFont(style: .headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 22)
            RHLinePlot(values: values)
                .frame(width: 50, height: 30)
                //.frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(Color.black)
            
            Text(priceText)
                .rhFont(style: .headline)
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 22)
        }.frame(height: 60)
    }
    
    
    var body: some View {
        VStack {
            if viewModel.isLoading || currentPlotData == nil {
                Text("Loading...")
                Text("Taking too long? Try again soon")
            } else {
                readyPageContent(plotData: currentPlotData!)
            }
        }
        .accentColor(rhThemeColor)
        .environment(\.rhLinePlotConfig, RHLinePlotConfig.default.custom(f: { (c) in
            c.useLaserLightLinePlotStyle = isLaserModeOn
        })).onAppear {
            self.viewModel.fetchOnAppear()
            self.stockChange(symbol: symbol)
            self.stockName(symbol: symbol)
        }.onDisappear {
            self.viewModel.cancelAllFetchesOnDisappear()
        }
    }
}

// MARK:- Components
extension RHChartView {
    func plotBody(plotData: PlotData) -> some View {
        let values = plotData.map { $0.price }
        let currentIndex = self.currentIndex ?? (values.count - 1)
        // For value stick
        let dateString = timeDisplayMode.dateFormatter()
            .string(from: plotData[currentIndex].time)
        
        let themeColor = values.last! >= values.first! ? rhThemeColor : rhRedThemeColor
        
        return RHInteractiveLinePlot(
            values: values,
            occupyingRelativeWidth: plotRelativeWidth,
            showGlowingIndicator: showGlowingIndicator,
            lineSegmentStartingIndices: plotDataSegments,
            segmentSearchStrategy: .binarySearch,
            didSelectValueAtIndex: { ind in
                self.currentIndex = ind
        },
            didSelectSegmentAtIndex: { segmentIndex in
                if segmentIndex != nil {
                    Haptic.onChangeLineSegment()
                }
        },
            valueStickLabel: { value in
                Text("\(dateString)")
                    .foregroundColor(.gray)
        })
            .frame(height: 280)
            .foregroundColor(themeColor)
    }
    
    func stockHeaderAndPrice(plotData: PlotData) -> some View {
        return HStack {
            VStack(alignment: .leading) {
                Text("\(self.symbol)")
                    .rhFont(style: .subheadline, weight: .heavy)
                Spacer()
                Text(self.stockName)
                    .font(Font.custom("CapsuleSansText", size: 30))
                buildMovingPriceLabel(plotData: plotData)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    func stockChange(symbol: String) {
        provider.getQuote(symbol) { (quote) in
            guard let stockQuote = quote else { return }
            print(stockQuote.changeValue.string)
            self.stockPriceChange = stockQuote.changeValue.string
            self.stockPercentChange = stockQuote.percentValue.string
        }

    }
    func stockName(symbol: String) {
        Finnhub.getDetail(symbol) { (profile, news, image) in
            guard let stockProfile = profile else { return }
            self.stockName = stockProfile.name
        }

    }
    
    func buildMovingPriceLabel(plotData: PlotData) -> some View {
        let currentIndex = self.currentIndex ?? (plotData.count - 1)
        return HStack(spacing: 2) {
            Text("$")
            MovingNumbersView(
                number: Double(plotData[currentIndex].price),
                numberOfDecimalPlaces: 2,
                verticalDigitSpacing: 0,
                animationDuration: 0.3,
                fixedWidth: 100) { (digit) in
                    Text(digit)
            }
            .mask(LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: .clear, location: 0),
                    Gradient.Stop(color: .black, location: 0.2),
                    Gradient.Stop(color: .black, location: 0.8),
                    Gradient.Stop(color: .clear, location: 1.0)]),
                startPoint: .top,
                endPoint: .bottom))
        }
        .rhFont(style: .title1, weight: .heavy)
    }
}
