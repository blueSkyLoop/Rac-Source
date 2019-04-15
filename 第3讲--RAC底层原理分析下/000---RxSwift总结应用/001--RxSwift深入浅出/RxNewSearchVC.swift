//
//  RxNewSearchVC.swift
//  001--RxSwift深入浅出
//
//  Created by Cooci on 2018/5/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RxNewSearchVC: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar{return searchController.searchBar}
    var myTableView:UITableView!
    let reuserId = "cell"
    let disposeB = DisposeBag()
    var shouldShowSearchResults = false //是否显示搜索结果
    var vm = SearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "搜索界面"
        self.view.backgroundColor = UIColor.orange
        myTableView = UITableView(frame: self.view.bounds, style: .plain)
        myTableView.register(SectionTableCell.self, forCellReuseIdentifier: SectionTableCell.description())
        self.view.addSubview(myTableView)
        
        // 搜索UI
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "请输入你要搜索的内容"
        searchBar.showsCancelButton = true
        myTableView.tableHeaderView = searchController.searchBar
//        definesPresentationContext = true
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
