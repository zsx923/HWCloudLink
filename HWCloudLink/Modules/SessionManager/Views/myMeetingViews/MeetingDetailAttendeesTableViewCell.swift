//
//  MeetingDetailAttendeesTableViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/10.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetingDetailAttendeesTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    static let cellID = "MeetingDetailAttendeesTableViewCell"
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    var dataSource: [ConfAttendee]?
    
    //  加载数据
    func loadData(attendees: [ConfAttendee], convener: String) {
        guard attendees.count != 0 else { return }
        var tempArray = [ConfAttendee]()
        for atte in attendees {
            if atte.name == convener {
                tempArray.insert(atte, at: 0)
                continue
            }
            tempArray.append(atte)
        }
        dataSource = tempArray
        self.CollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: MeetingDetailAttItemCollectionViewCell.cellID, for: indexPath) as! MeetingDetailAttItemCollectionViewCell
        let confModel:ConfAttendee = self.dataSource?[indexPath.row] ?? ConfAttendee();
        cell.nameLabel.text = indexPath.item == 0 ? "\(confModel.name ?? "")(\(tr("召集人")))" : confModel.name;
        cell.picImageView.image = getUserIconWithAZ(name: confModel.name)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SCREEN_WIDTH-1.0)/5.0, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        
        self.CollectionView.register(UINib.init(nibName: MeetingDetailAttItemCollectionViewCell.cellID, bundle: nil), forCellWithReuseIdentifier: MeetingDetailAttItemCollectionViewCell.cellID)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
