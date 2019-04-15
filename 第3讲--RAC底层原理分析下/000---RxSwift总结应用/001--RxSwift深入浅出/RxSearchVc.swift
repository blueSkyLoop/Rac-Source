//
//  RxSearchVc.swift
//  001---RxSwift
//
//  Created by Cooci on 2018/5/11.
//  Copyright © 2018年 Cooci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class RxSearchVC: UIViewController,UISearchResultsUpdating,UISearchBarDelegate {

    //通过参数searchResultsController传nil来初始化UISearchController，意思是我们告诉search controller我们会用相同的视图控制器来展示我们的搜索结果，如果我们想要指定一个不同的view controller，那就会被替代为显示搜索结果。
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar{return searchController.searchBar}
    var myTableView:UITableView!
    let reuserId = "cell"
    let disposeB = DisposeBag()
    var shouldShowSearchResults = false //是否显示搜索结果
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.myTableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        self.view.addSubview(self.myTableView)
        self.myTableView.register(SectionTableCell.self, forCellReuseIdentifier: reuserId)
        
        //设置代理，searchResultUpdater是UISearchController的一个属性，它的值必须实现UISearchResultsUpdating协议，这个协议让我们的类在UISearchBar文字改变时被通知到，我们之后会实现这个协议。
        searchController.searchResultsUpdater = self
        //默认情况下，UISearchController暗化前一个view，这在我们使用另一个view controller来显示结果时非常有用，但当前情况我们并不想暗化当前view，即设置开始搜索时背景是否显示
        searchController.dimsBackgroundDuringPresentation = false
        //设置默认显示内容
        searchController.searchBar.placeholder = "请输入你要搜索的内容"
        //设置searchBar的代理
        searchController.searchBar.delegate = self
        //设置searchBar自适应大小
        searchController.searchBar.sizeToFit()
        //设置definesPresentationContext为true，我们保证在UISearchController在激活状态下用户push到下一个view controller之后search bar不会仍留在界面上。
        searchController.definesPresentationContext = true
        //将searchBar设置为tableview的头视图
        myTableView.tableHeaderView = searchController.searchBar
        //取消按钮
        searchBar.showsCancelButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(pushNewSearchVC))

    }
    
    @objc func pushNewSearchVC(){
    self.navigationController?.pushViewController(RxSwiftNetWorkingVC(), animated: true)
    }
    
    //这个updateSearchResultsForSearchController(_:)方法是UISearchResultsUpdating中唯一一个我们必须实现的方法。当search bar 成为第一响应者，或者search bar中的内容被改变将触发该方法.不管用户输入还是删除search bar的text，UISearchController都会被通知到并执行上述方法。
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        print(searchString ?? "234")
    }
    
    //开始进行文本编辑，设置显示搜索结果，刷新列表
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        myTableView.reloadData()
    }
    
    //点击Cancel按钮，设置不显示搜索结果并刷新列表
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        myTableView.reloadData()
    }
    
    //点击搜索按钮，触发该代理方法，如果已经显示搜索结果，那么直接去除键盘，否则刷新列表
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults{
            shouldShowSearchResults = true
            myTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }

}

