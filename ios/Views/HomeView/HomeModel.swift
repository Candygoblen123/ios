//
//  HomeModel.swift
//  ios
//
//  Created by Mason Phillips on 2/2/21.
//

import Foundation
import RxCocoa
import RxFlow
import RxSwift

class HomeModel: BaseModel {
    let streamers = BehaviorRelay<YTStreamers?>(value: nil)
    
    func fetchCurrentStreams() {
        services.api.getLiveStreamers()
            .asObservable()
            .bind(to: streamers)
            .disposed(by: bag)
    }
}

protocol HomeModelInput {
    func fetchCurrentStreams()
}
protocol HomeModelOutput {
    var streamers: BehaviorRelay<YTStreamers?> { get }
    var streamersDriver: Driver<YTStreamers?> { get }
}
protocol HomeModelType {
    var input : HomeModelInput  { get }
    var output: HomeModelOutput { get }
}

extension HomeModel: HomeModelType {
    var input : HomeModelInput  { self }
    var output: HomeModelOutput { self }
}

extension HomeModel: HomeModelInput {
    
}
extension HomeModel: HomeModelOutput {
    var streamersDriver: Driver<YTStreamers?> {
        return streamers.asDriver()
    }
}
