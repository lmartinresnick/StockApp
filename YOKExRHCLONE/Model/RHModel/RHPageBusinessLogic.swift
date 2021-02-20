//
//  RHPageBusinessLogic.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Combine

class RobinhoodPageBusinessLogic {
    typealias APIResponse = RHChartAPIResponse
    
    let symbol: String
    @Published var intradayResponse: APIResponse?
    @Published var dailyResponse: APIResponse?
    @Published var weeklyResponse: APIResponse?
    @Published var monthlyResponse: APIResponse?
    
    private static let mapTimeSeriesToResponsePath: [RHChartAPI.TimeSeriesType: ReferenceWritableKeyPath<RobinhoodPageBusinessLogic, APIResponse?>] = [
        .intraday: \.intradayResponse,
        .daily: \.dailyResponse,
        .weekly: \.weeklyResponse,
        .monthly: \.monthlyResponse
    ]
    
    var storage = Set<AnyCancellable>()
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    func fetch(timeSeriesType: RHChartAPI.TimeSeriesType) {
        RHChartAPI(symbol: symbol, timeSeriesType: timeSeriesType).publisher
            .assign(to: Self.mapTimeSeriesToResponsePath[timeSeriesType]!, on: self)
            .store(in: &storage)
    }
}
