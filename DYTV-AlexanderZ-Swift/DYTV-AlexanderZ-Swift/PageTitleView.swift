//
//  PageTitleView.swift
//  DYTV-AlexanderZ-Swift
//
//  Created by Alexander Zou on 16/9/23.
//  Copyright © 2016年 Alexander Zou. All rights reserved.
//

import UIKit

protocol PageTitleViewDelegate : class {
    func pageTitleView(titleView : PageTitleView, selectedIndex : Int)
}

private let kScrollLineH : CGFloat = 2
private let kNormalColor : (CGFloat,CGFloat,CGFloat) = (85,85,85)
private let kMoveColor : (CGFloat,CGFloat,CGFloat) = (255,128,0)

class PageTitleView: UIView {
    
    // 定义属性
    private var titles : [String]
    private var currentIndex : Int = 0
    weak var delegate : PageTitleViewDelegate?
    
    
    // 懒加载属性
    private lazy var titleLabels : [UILabel] = [UILabel]()
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false                     //点击回到头部
        scrollView.bounces = false
        return scrollView
    }()
    
    private lazy var scrollLine : UIView = {
       
        let scrollLine = UIView()
        scrollLine.backgroundColor = UIColor.orangeColor()
        return scrollLine
    }()
    
    // 自定义构造函数
    init(frame: CGRect, title:[String]) {
        
        self.titles = title
        
        super.init(frame:frame)
        
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension PageTitleView {
    
    private func setupUI(){
        
        // 1.添加UIScrollView
        addSubview(scrollView)
        scrollView.frame = bounds
        
        // 2.添加Title对应的label
        setupTitleLabels()
        
        // 3.设置底线和滚动条
        setupButtomLineAndScrollLine()
        
    }
    
    private func setupTitleLabels(){
        
        // 0.提前确定label的frame
        let labelW : CGFloat = frame.width / CGFloat(titles.count)
        let labelH : CGFloat = frame.height - kScrollLineH
        
        for (index,title) in titles.enumerate() {
            // 1.创建lable
            let label = UILabel()
            
            // 2.创建lable属性
            label.text = title
            label.tag = index
            label.font = UIFont.systemFontOfSize(16.0)  //字体大小
            label.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
            label.textAlignment = .Center               //居中
            
            // 3.设置label的frame
            let labelX : CGFloat = labelW * CGFloat(index)
            let labelY : CGFloat = 0
            label.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
            
            scrollView.addSubview(label)
            titleLabels.append(label)
            
            // 5.给label添加手势
            label.userInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self,action: #selector(self.titleLabelClick(_:)))
            label.addGestureRecognizer(tapGes)
            
        }
        
        
        
    }
    
    private func setupButtomLineAndScrollLine(){
        
        // 1.设置底线
        let buttomLine = UIView()
        buttomLine.backgroundColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
        let lineH : CGFloat = 0.5
        buttomLine.frame = CGRect(x: 0, y: frame.height - lineH, width: frame.width, height: lineH)
        addSubview(buttomLine)
        
        // 2.添加scrollLine
        scrollView.addSubview(scrollLine)
        // 2.1获取lable
        guard let firstLabel = titleLabels.first else { return }
        firstLabel.textColor = UIColor(r: kMoveColor.0, g: kMoveColor.1, b: kMoveColor.2)
        scrollLine.frame = CGRect(x: firstLabel.frame.origin.x, y: frame.height - kScrollLineH, width: firstLabel.frame.width, height: kScrollLineH)
        
    }
}

// 监听label的点击事件
extension PageTitleView {
    
    @objc private func titleLabelClick(taGes : UITapGestureRecognizer) {
        
//        print("点击了Label")
        
        // 0.获取当前label的下标值
        guard let currentLabel = taGes.view as? UILabel else { return }
        
        // 1.如果重复点击同一个title,直接返回
        if currentLabel.tag == currentIndex { return }
        
        // 2.获取之前的label
        let oldLabel = titleLabels[currentIndex]
        
        // 3.切换文字颜色
        currentLabel.textColor = UIColor(r: kMoveColor.0, g: kMoveColor.1, b: kMoveColor.2)
        oldLabel.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
        
        // 4.保存最新label的下标
        currentIndex = currentLabel.tag
        
        // 5.滚动条跟随滚动
        let scrollLineX = CGFloat (currentLabel.tag) * scrollLine.frame.width
        UIView.animateWithDuration(0.15) { 
            self.scrollLine.frame.origin.x = scrollLineX
        }
        
        // 6.代理
        delegate?.pageTitleView(self, selectedIndex: currentIndex)
        
    }
}


extension PageTitleView {
    func setTitleWithProgress(progress : CGFloat, sourceIndex : Int, targetIndex : Int){
        
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        
        // 横线渐变
        let totalX =  targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let moveX = totalX * progress
        scrollLine.frame.origin.x = sourceLabel.frame.origin.x + moveX
        
        // 文字渐变
        // 取出变化范围
        let colorDelta = (kMoveColor.0 - kNormalColor.0,kMoveColor.1 - kNormalColor.1,kMoveColor.2 - kNormalColor.2)
        sourceLabel.textColor = UIColor(r: kMoveColor.0 - colorDelta.0 * progress, g: kMoveColor.1 - colorDelta.1 * progress, b: kMoveColor.2 - colorDelta.2 * progress)
        targetLabel.textColor = UIColor(r: kNormalColor.0 + colorDelta.0 * progress, g: kNormalColor.1 + colorDelta.1 * progress, b: kNormalColor.2 + colorDelta.2 * progress)
        
        // 记录最新index
        currentIndex = targetIndex
        
    }
}