//
//  NumberKeyboardController.swift
//  NumberKeyboard
//
//  Created by xuyangbo on 2020/5/30.
//  Copyright © 2020 coderybxu. All rights reserved.
//

import UIKit

let numberKeyboardCellID = "NumberKeyboardCell"

protocol NumberBoardAble {
    func numberBoardText(_ resuleString : String, _ controller: UIViewController)
}
class NumberKeyboardController: UIViewController {
    
    var interfaceOrientationChangeValue: UIInterfaceOrientation = .portrait {
        willSet{
            if keyboardCollectionView != nil {
                keyboardCollectionView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var keyboardCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backView: UIView!
    
    var delegate: NumberBoardAble?
    /// 数据源
    private lazy var dataArray = ["1","2","3","4","5","6","7","8","9","*","0","#"]
    
    private var secureString = ""
    private var eyeString = ""
    private var eyeButtonIsSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGesture()
    }
    
    // 显示/隐藏密码按钮点击
    @IBAction func eyeButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        eyeButtonIsSelected = sender.isSelected
        self.textField.text = sender.isSelected ? eyeString : secureString
    }
    
    private func setupUI() {
        keyboardCollectionView.register(UINib(nibName: numberKeyboardCellID, bundle: nil), forCellWithReuseIdentifier: numberKeyboardCellID)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        bgView.isUserInteractionEnabled = true
    }
    
    private func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        bgView.addGestureRecognizer(gesture)
        backView.addGestureRecognizer(gesture)
    }
    
    deinit {
        CLLog("NumberKeyboardController deinit")
    }
}

extension NumberKeyboardController {
    @objc private func dismissSelf() {
        textField.text = ""
        dismiss(animated: true, completion: nil)
    }
}

//MARK:-  =============UICollectionViewDelegate, UICollectionViewDataSource===============
extension NumberKeyboardController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: numberKeyboardCellID, for: indexPath) as! NumberKeyboardCell
        cell.numberLable.text = dataArray[indexPath.item]
        cell.numberLable.font = UIFont.systemFont(ofSize: 23)
        if indexPath.item == 9 {
            cell.numberLable.font = UIFont.systemFont(ofSize: 50)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = keyboardCollectionView.frame.height / 4
        let itemsSizeForPortrait = CGSize(width: keyboardCollectionView.frame.width / 3, height: height)
        let itemsSizeForOther = CGSize(width: keyboardCollectionView.frame.width / 3, height: height )
        return interfaceOrientationChangeValue == .portrait ? itemsSizeForPortrait : itemsSizeForOther
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // change at xuegd 2020-12-29 : 密码默认为6位，且显示为"•"
        eyeString += dataArray[indexPath.item]
        secureString += "•"
        textField.text! = eyeButtonIsSelected ? eyeString : secureString
        delegate?.numberBoardText(dataArray[indexPath.item] , self)
    }
    
    
}
