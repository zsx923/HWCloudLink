//
//  PreMeetingAttendeeViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class PreMeetingAttendeeViewController: UICollectionViewController {
    fileprivate var isDeleteStatus = false
    //目前记录选中的与会者列表
    var preCurrentAttendeeArray: [LdapContactInfo] = []

    //记录上次选中的列表
//    private var hasBeDelectConfAttendees: [ConfAttendee] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        hasBeDelectConfAttendees = APP_DELEGATE.currentAttendeeArray
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        preCurrentAttendeeArray = SessionManager.shared.currentAttendeeArray
        // set title
        self.setViewUI()
        
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // Register cell classes
        // 1. 定义collectionView的布局类型，流布局
        let layout = UICollectionViewFlowLayout()
        // 2. 设置cell的大小
        layout.itemSize = CGSize(width: 82.5, height: CollectionImageTopTextCell.CELL_HEIGHT)
        // 3. 滑动方向
        /**
         默认方向是垂直
         UICollectionViewScrollDirection.vertical  省略写法是.vertical
         水平方向
         UICollectionViewScrollDirection.horizontal 省略写法是.horizontal
         */
        layout.scrollDirection = .vertical
        // 4. 每个item之间最小的间距
        layout.minimumInteritemSpacing = 0
        // 5. 每行之间最小的间距
        layout.minimumLineSpacing = 0
        // 6. 设置一个layout
        self.collectionView.collectionViewLayout = layout
        
        // 7. collectionViewCell的注册
        self.collectionView?.register(UINib.init(nibName: CollectionImageTopTextCell.CELL_ID, bundle: nil), forCellWithReuseIdentifier: CollectionImageTopTextCell.CELL_ID)
    

        // Do any additional setup after loading the view.
        
        // 接收广播
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUpdateSelectedAttendee(notification:)), name: NSNotification.Name.init(rawValue: UpdataInvitationAttendee), object: nil)
    }
    
    // MARK: - 接收广播通知
    // MARK: - 接听邀请选中与会者通知
    @objc func notificationUpdateSelectedAttendee(notification: Notification) {
//        hasBeDelectConfAttendees = APP_DELEGATE.currentAttendeeArray
        preCurrentAttendeeArray = SessionManager.shared.currentAttendeeArray
        self.collectionView.reloadData()
        self.setInitData()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        // 确定
        self.isDeleteStatus = false
        self.setViewUI()
        self.collectionView.reloadData()
        SessionManager.shared.currentAttendeeArray = preCurrentAttendeeArray
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: UpdataInvitationAttendee), object: nil)
    }
    
    func setViewUI() {
        self.setNavigationItemShow(isShow: self.isDeleteStatus)
        
        self.setInitData()
    }
    
    func setInitData() {
        let nav = self.navigationController as? BaseNavigationController
        self.title = tr("与会者") + "(\(preCurrentAttendeeArray.count+1))"
        nav?.updateTitle(title:  self.title!)
        
        self.collectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UICollectionViewDelegate 代理方法的实现
    // MARK: numberOfSections 代理方法
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: numberOfItemsInSection  代理方法
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if preCurrentAttendeeArray.count == 0 {
            return 2
        }
        if self.isDeleteStatus {
            return preCurrentAttendeeArray.count + 2
        }
        return preCurrentAttendeeArray.count + 3
    }
    
    // MARK: cellForItemAt  代理方法
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionImageTopTextCell.CELL_ID, for: indexPath) as! CollectionImageTopTextCell
        
        cell.setDeleteBtnHiden(isHidden: !self.isDeleteStatus)
    
        // Configure the cell
        if preCurrentAttendeeArray.count == 0 {
            // 只有添加按钮
            cell.showImageView.image = UIImage.init(named: "invite_attendee_add")
            cell.showTitleLabel.text = tr("添加")
            cell.setDeleteBtnHiden(isHidden: true)
            switch indexPath.row {
            case 0:
                cell.showImageView.image = UIImage.init(named: "invite_attendee_add")
                cell.showTitleLabel.text = tr("添加")
                cell.setDeleteBtnHiden(isHidden: true)
            case 1:
                cell.showImageView.image = getUserIconWithAZ(name: ("(" + tr("我") + ")"))
                cell.showTitleLabel.text = ("(" + tr("我") + ")")
                cell.setDeleteBtnHiden(isHidden: true)
            default:
                break
            }
        } else {
            // 有添加和删除按钮
            switch indexPath.row {
            case 0:
                cell.showImageView.image = UIImage.init(named: "invite_attendee_add")
                cell.showTitleLabel.text = tr("添加")
                cell.setDeleteBtnHiden(isHidden: true)
            case 1:
                if isDeleteStatus {
                    cell.showImageView.image = getUserIconWithAZ(name: ("(" + tr("我") + ")"))
                    cell.showTitleLabel.text = ("(" + tr("我") + ")")
                    cell.setDeleteBtnHiden(isHidden: true)
                }else{
                    cell.showImageView.image = UIImage.init(named: "invite_attendee_delete")
                    cell.showTitleLabel.text = tr("删除")
                    cell.setDeleteBtnHiden(isHidden: !self.isDeleteStatus)
                }
            case 2:
                cell.showImageView.image = getUserIconWithAZ(name: ("(" + tr("我") + ")"))
                cell.showTitleLabel.text = ("(" + tr("我") + ")")
                cell.setDeleteBtnHiden(isHidden: !self.isDeleteStatus)
                if isDeleteStatus {
                    fallthrough
                }
            default:
                let attendee = self.isDeleteStatus ? preCurrentAttendeeArray[indexPath.row - 2] : preCurrentAttendeeArray[indexPath.row - 3]
                cell.showImageView.image = getUserIconWithAZ(name: attendee.name)
                cell.showTitleLabel.text = attendee.name
                if indexPath.row == 1 {
                    cell.setDeleteBtnHiden(isHidden: true)
                }
            }
        }
        
        if self.isDeleteStatus {
            cell.deleteBtn.tag = indexPath.row - 2
            cell.deleteBtn.addTarget({ (sender) in
                // 删除元素
                self.preCurrentAttendeeArray.remove(at: sender!.tag)
                self.collectionView.reloadData()
                self.setViewUI()
            }, andEvent: UIControl.Event.touchUpInside)
        }
    
        return cell
    }
    
    // MARK: didSelectItemAt 的代理方法
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("(\((indexPath as NSIndexPath).section), \((indexPath as NSIndexPath).row))")
        
        if indexPath.row == 0 {
            // 添加
            let storyboard = UIStoryboard.init(name: "SearchAttendeeViewController", bundle: nil)
            let searchAttendee = storyboard.instantiateViewController(withIdentifier: "SearchAttendeeView") as! SearchAttendeeViewController
//            searchAttendee.hasBeDelectConfAttendees = hasBeDelectConfAttendees
            searchAttendee.isFromPreMeeting = true
            self.navigationController?.pushViewController(searchAttendee, animated: true)
        } else if indexPath.row == 1 {
            // 删除
            self.isDeleteStatus = true
            self.setViewUI()
        }
    }
   
    
    func setNavigationItemShow(isShow: Bool) {
        if isShow {
            let rightBarBtnItem = UIBarButtonItem.init(title: tr("确定"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
            self.navigationItem.rightBarButtonItem = rightBarBtnItem
            self.navigationItem.rightBarButtonItem?.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }

}
