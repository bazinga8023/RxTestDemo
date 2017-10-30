//
//  ViewController.swift
//  TestDemo
//
//  Created by 张俊安 on 2017/9/10.
//  Copyright © 2017年 cppteam. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let touchView = TouchView()
        touchView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        touchView.backgroundColor = UIColor.red
        view.addSubview(touchView)
        
//        touchView.touchDelegate = self
        
        touchView.rx.touchPoint
            .subscribe(onNext: { point in
                print(point)
            })
            .disposed(by: disposeBag)
        
    }


}

//extension ViewController: TouchPointDelegate {
//    
//    func touch(at point: CGPoint, in view: UIView) {
//        print(point)
//    }
//
//}
















