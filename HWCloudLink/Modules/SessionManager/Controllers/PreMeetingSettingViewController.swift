//
//  PreMeetingSettingViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class PreMeetingSettingViewController: UITableViewController,UITextFieldDelegate {
    
    typealias PasswordTwxtCallBack = (_ password: String)->()
    
    var passwordTwxtCallBack: PasswordTwxtCallBack?
    // 麦克风
    @IBOutlet weak var microphoneTitleLabel: UILabel!
    // 麦克风 - Switch
    @IBOutlet weak var microphoneSwitch: UISwitch!
    // 摄像头
    @IBOutlet weak var videoTitleLabel: UILabel!
    // 摄像头 - Switch
    @IBOutlet weak var videoSwitch: UISwitch!
    // 会议/主持人密码
    @IBOutlet weak var comerPasswordTitleLabel: UILabel!
    // 会议/主持人密码 - Switch
    @IBOutlet weak var comerPasswordSwitch: UISwitch!
    // 设置密码/输入密码
    @IBOutlet weak var passwordTitleLabel: UILabel!
    // 设置密码/输入密码 - TextField
    @IBOutlet weak var passwordValueTextField: UITextField!
    // 时区
    @IBOutlet weak var timeZoneTitleLabel: UILabel!
    // 时区 - 数据
    @IBOutlet weak var timeZoneValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set title
        self.title = tr("高级设置")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        initView()
        initDate()
    }
    
    
    func initView(){
        // 去分割线
        self.tableView.separatorStyle = .none
        self.passwordValueTextField.delegate = self
        self.comerPasswordSwitch.setOn(false, animated: true)
        
        passwordValueTextField.isSecureTextEntry = true
        passwordValueTextField.clearButtonMode = .whileEditing
    }
    
    func initDate() {
        
        let microphoneSwitch = UserDefaults.standard.bool(forKey: DICT_SAVE_MICROPHONE_IS_ON)
        self.microphoneSwitch.isOn = microphoneSwitch

        let videoSwitch = UserDefaults.standard.bool(forKey: DICT_SAVE_VIDEO_IS_ON)
        self.videoSwitch.isOn = videoSwitch
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        
        UserDefaults.standard.set(self.microphoneSwitch.isOn, forKey: DICT_SAVE_MICROPHONE_IS_ON)
        UserDefaults.standard.set(self.videoSwitch.isOn, forKey: DICT_SAVE_VIDEO_IS_ON)

        // 传递密码如果有的话
        if passwordValueTextField.text != "" && passwordTwxtCallBack != nil {
            passwordTwxtCallBack?(passwordValueTextField.text ?? "")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func comerPasswordSwitchValueChange(_ sender: Any) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            if !self.comerPasswordSwitch.isOn{
                cell.isHidden = true
            }else{
                cell.isHidden = false
            }
        }
    }
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
