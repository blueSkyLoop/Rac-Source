//
//  RxSwiftNetWorkingVC.swift
//  001--RxSwift深入浅出
//
//  Created by Cooci on 2018/5/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxSwiftNetWorkingVC: UIViewController {

    let surStr = "https://www.douban.com/j/app/radio/channels"
    let disposeB = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(pushNewSearchVC))
        self.title = "RxSwiftNetWorkingVC"
        self.view.backgroundColor = UIColor.orange
    }

    @objc func pushNewSearchVC(){
        self.navigationController?.pushViewController(RxNewSearchVC(), animated: true)
    }
    
   

}
