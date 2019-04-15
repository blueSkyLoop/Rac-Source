//
//  TableViewTestVC.swift
//  001--RxSwift深入浅出
//
//  Created by Cooci on 2018/5/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TableViewTestVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let disposeBag = DisposeBag()
    var tableView : UITableView!
    let reuserId = "reuserId"

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "一般的table"
        testUITableView()
//        tableView = UITableView(frame: self.view.bounds, style: .plain)
//        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.description())
//        self.view.addSubview(tableView)
        
    }

    func testUITableView(){
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.description())
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.description(), for: indexPath) as? MyTableViewCell
        cell?.getvalue(titleStr: "\(indexPath.row)", nameStr: "  Cooci  \(indexPath.row)")
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }

}

class MyTableViewCell: UITableViewCell {
    
    var titlteLabel:UILabel?
    var nameLabel:UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titlteLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: self.contentView.bounds.height))
        self.contentView.addSubview(self.titlteLabel!)
        
        self.nameLabel = UILabel(frame: CGRect(x: self.titlteLabel!.bounds.maxX, y: 0, width: 100, height: self.contentView.bounds.height))
        self.contentView.addSubview(self.nameLabel!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getvalue(titleStr:String,nameStr:String){
        self.titlteLabel?.text = titleStr
        self.nameLabel?.text = nameStr
    }
    
}

