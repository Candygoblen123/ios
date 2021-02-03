//
//  HomeView.swift
//  ios
//
//  Created by Mason Phillips on 2/1/21.
//

import UIKit
import Neon
import FLEX
import RxSwift
import RxCocoa
import RxDataSources

class HomeView: UIViewController {
    let model    : HomeModelType
    var presenter: HomePresenter { HomePresenter(self) }
    let bag = DisposeBag()
    
    let liveTable: UITableView
    
    var rightButton: UIBarButtonItem {
        let b = UIBarButtonItem(title: "\u{f085}", style: .plain, target: self, action: nil)
        b.setTitleTextAttributes([.font: UIFont(name: "FontAwesome5Pro-Regular", size: 20)!], for: .normal)
        b.setTitleTextAttributes([.font: UIFont(name: "FontAwesome5Pro-Solid", size: 20)!], for: .selected)
        
        return b
    }

    required init(initializationItems: ControllerInitializationItems) {
        model = HomeModel(initializationItems)
        liveTable = UITableView(frame: .zero, style: .insetGrouped)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Streams"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = rightButton
        
        let flexGesture = UITapGestureRecognizer(target: self, action: #selector(showFlex))
        flexGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(flexGesture)
        
        liveTable.register(StreamCell.self, forCellReuseIdentifier: StreamCell.identifier)
        liveTable.rx.setDelegate(self).disposed(by: bag)
        view.addSubview(liveTable)
        model.output.streamers
            .compactMap { $0?.sections() }
            .bind(to: liveTable.rx.items(dataSource: presenter.dataSource))
            .disposed(by: bag)
        
        model.input.fetchCurrentStreams()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        liveTable.fillSuperview()
    }
    
    @objc func showFlex() {
        FLEXManager.shared.showExplorer()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension HomeView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
