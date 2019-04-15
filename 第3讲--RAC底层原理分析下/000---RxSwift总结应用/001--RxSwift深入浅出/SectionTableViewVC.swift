//
//  SectionTableViewVC.swift
//  001--RxSwift深入浅出
//
//  Created by Cooci on 2018/5/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SectionTableViewVC: UIViewController {

    let disposeBag = DisposeBag()
    var tableView : UITableView!
    var dataS = GithubData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "分组显示的Table"
        self.view.backgroundColor = UIColor.orange
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.register(SectionTableCell.self, forCellReuseIdentifier: SectionTableCell.description())
        self.view.addSubview(tableView)
        // 右侧item push
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(pushSearchVC))
        
    }
    
    @objc func pushSearchVC(){
        self.navigationController?.pushViewController(RxSearchVC(), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class SectionTableCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
//        print(#function)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


