//
//  DBUtils.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/16.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    
    // 创建单例
    static let shared = DBManager()
    
    private let databaseFileName = "cloud_link.db"               // 数据库的名称
    private var pathToDatabase: String!                              // 数据库的地址
    var database: FMDatabase!
    let dbVersion = 1.0
    override init() {
        super.init()
        // 获取数据库的地址
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        pathToDatabase = documentDirectory.appending("/\(databaseFileName)")
    }
    
    func createDB() -> Bool {
        var created = false
        //如果数据库文件不存在那么就创建，存在就不创建
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            if openDB(){
                //创建初始表
                let sql = "create table if not exists cl_user_call_log (user_call_log_id integer primary key not null,self_account text not null,user_id integer not null,user_name text not null,number text not null,image_url text not null,title text not null,call_type integer not null,meeting_type integer not null, talk_time integer not null, is_answer tinyint not null, is_coming tinyint not null, create_time DATETIME default (datetime('now', 'localtime')));"
                  
                    +  "create table if not exists cl_local_contact (local_contact_id integer primary key not null,nameForPinYin text not null,name text not null,self_account text not null,first_charactor text not null,number text not null,mobile text not null,fax text not null,campany text not null,depart text not null,post text not null,e_mail text not null,address text not null,remark text not null,type integer not null,create_time DATETIME default (datetime('now', 'localtime')));"
                    +  "create table if not exists cl_favourite_contact (favourite_contact_id integer primary key not null,id text not null,uri text not null,uc_acc text not null,staff_no text not null,name text not null,nick_name text not null,qpinyin text not null,spinyin text not null,home_phone text not null,office_phone text not null,mobile text not null,other_phone text not null,address text not null,email text not null,duty text not null,fax text not null,gender text not null,corp_name text not null,dept_name text not null,web_site text not null,desc text not null,zip text not null,signature text not null,image_id text not null,position text not null,location text not null,tzone text not null,avtool text not null,device text not null,terminal_type text not null,confid text not null,access_num text not null,chair_pwd text not null,create_time DATETIME default (datetime('now', 'localtime')));"
                    + "create table if not exists user_setting_table (self_account text primary key not null,videpDefinitionPolicy integer default 1,logUploadIsOn integer default 0,languageSwitch text default 'China', micIsOpen integer default 1,videoIsOpen integer default 1,shakeIsOpen integer default 1,ringIsOpen integer default 1,remark1 text default '',remark2 text default '',remark3 text default '',remark4 text default '');"
                if database.executeStatements(sql) {
                    print("数据库初始化成功")
                    created = true
                }else{
                    created = false
                    print("数据库初始化失败")
                    print("Failed to insert initial data into the database.")
                    print(database.lastError(), database.lastErrorMessage())
                }
                closeDB()
            }else{
                print("数据库打开失败")
                created = false
            }
        }
        else
        {
            created = true
        }
        return created
    }
    
    
    func addUserSettingTable() -> Bool {
        var created = false
        let tableVersion = NSObject.getUserDefaultValue(withKey: DICT_SAVE_UserSetingTable_Version) as? String ?? "0"
        let versionDouble = Double(tableVersion)
        if versionDouble == self.dbVersion {
            if openDB() {
                let sql = "create table if not exists user_setting_table (self_account text primary key not null,videpDefinitionPolicy integer default 1,logUploadIsOn integer default 0,languageSwitch text default 'China', micIsOpen integer default 1,videoIsOpen integer default 1,shakeIsOpen integer default 1,ringIsOpen integer default 1,remark1 text default '',remark2 text default '',remark3 text default '',remark4 text default '');"
                if database.executeStatements(sql) {
                    print("添加用户配置成功")
                    created = true
                    NSObject.userDefaultSaveValue(String(self.dbVersion), forKey: DICT_SAVE_UserSetingTable_Version)
                }else{
                    created = false
                    print("添加用户配置成功")
                    print("Failed to add initial data into the database.")
                    print(database.lastError(), database.lastErrorMessage())
                }
                closeDB()
            } else {
                print("数据库打开失败")
            }
        } else {
            print("表已添加")
            created = true
        }
        return created
    }
    
    func openDB() -> Bool {
        database = FMDatabase(path: pathToDatabase)
        if database != nil{
        //数据库是否被打开
            if database.open() {
                print("数据库打开成功")
                return true
            }else{
                print("数据库打开失败")
                return false
            }
        }
        return true
    }
    
    func closeDB(){
        if database != nil {
            if database.close() {
                print("数据库关闭成功")
            }else{
                print("数据库关闭失败")
            }
        }
    }
}
