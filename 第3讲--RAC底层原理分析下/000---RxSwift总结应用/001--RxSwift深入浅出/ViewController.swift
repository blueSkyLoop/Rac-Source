//
//  ViewController.swift
//  001--RxSwift深入浅出
//
//  Created by Cooci on 2018/5/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposB = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testUI()
        testRxSwiftCreat()
    }
    
    func testRxSwiftCreat(){

    }
    
    func testUI(){
        let textf = UITextField(frame: CGRect(x: 50, y: 50, width: 100, height: 30))
        textf.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(textf)
        
        let label = UILabel(frame: CGRect(x: 50, y: 90, width: 200, height: 30))
        label.textColor = UIColor.orange
        self.view.addSubview(label)
        
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 50, y: 120, width: 100, height: 30)
        btn.setTitle("登录", for:UIControlState.normal)
        self.view.addSubview(btn)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

enum MyError:Error {
    case errorA
    case errorB
    var errorType: String{
        switch self {
        case .errorA:
            return "this is A error"
        case .errorB:
            return "this is B error"
        }
    }
    
}



