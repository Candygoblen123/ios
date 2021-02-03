//
//  HomePresenter.swift
//  ios
//
//  Created by Mason Phillips on 2/2/21.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift

fileprivate let cellOffset: CGFloat = 20
typealias YTModel = SectionModel<String, YTStreamers.Streamer>

class HomePresenter: NSObject {
    let controller: HomeView
    let dataSource: RxTableViewSectionedReloadDataSource<StreamersModel>
    
    let bag = DisposeBag()
    
    init(_ controller: HomeView) {
        self.controller = controller

        dataSource = RxTableViewSectionedReloadDataSource<StreamersModel> { source, table, index, item -> UITableViewCell in
            let cell = table.dequeueReusableCell(withIdentifier: StreamCell.identifier)!
            (cell as? StreamCell)?.configure(with: item)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { source, index in
            return source.sectionModels[index].title
        }        
    }
}

extension HomePresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

struct StreamersModel: SectionModelType {
    typealias Item = YTStreamers.Streamer
    var items: [YTStreamers.Streamer]
    var title: String
    
    init(original: StreamersModel, items: [YTStreamers.Streamer]) {
        self = original
        self.items = items
    }
    
    init(_ items: [Self.Item], title: String) {
        self.items = items
        self.title = title
    }
}
