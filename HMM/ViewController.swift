//
//  ViewController.swift
//  HMM
//
//  Created by JuanFelix on 4/23/16.
//  Copyright © 2016 JuanFelix. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var userList:Array<User> = []
    var isPortrait: Bool = true
    
    @IBOutlet weak var tblUserList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        userList = [["name":"Juan","mobile":"iPhone5"],["name":"Felix","mobile":"Glaxy"]]
        fetchAllUserList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewAction(sender: UIBarButtonItem) {
        tblUserList.setEditing(false, animated: false)
        let alert = UIAlertController(title: "Add", message: "Input userName and mobileName", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "UserName"
        }
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "MobileName"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) in
            let txtF1 = alert.textFields!.first
            let txtF2 = alert.textFields!.last
            self.addNewInfo((txtF1?.text)!, mobile: (txtF2?.text)!)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addNewInfo(name:String,mobile:String) {
        if name.isEmpty || mobile.isEmpty {
            let alert = UIAlertController(title: "Info", message: "Message cannot be empty", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            insertANewData(name, mobileName: mobile)
            tblUserList.reloadData()
        }
    }
    
    //弹出修改用户名Alert
    func showUpdateConotrol(oldName:String,newName:String) {
        if newName.isEmpty {
            let alert = UIAlertController(title: "Info", message: "Message cannot be empty", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            updateUserName(oldName,newName: newName)
        }
    }
    
    //插入数据
    func insertANewData(userName:String,mobileName:String) {
        let context = self.getManagedObjectContext()
        //创建Mobile 对象1
        let mobile1 = NSEntityDescription.insertNewObjectForEntityForName("Mobile", inManagedObjectContext: context) as! Mobile
        mobile1.name = "\(mobileName)" + "A"
        mobile1.system = arc4random() % 2 == 0 ? "iOS" : "Android"
        //创建Mobile 对象2
        let mobile2 = NSEntityDescription.insertNewObjectForEntityForName("Mobile", inManagedObjectContext: context) as! Mobile
        mobile2.name = "\(mobileName)" + "B"
        mobile2.system = arc4random() % 2 == 0 ? "iOS" : "Android"
        //创建User 对象
        let user = User(entity: NSEntityDescription.entityForName("User", inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
        user.name = userName
        user.address = "天府大道北段1480号"
        user.sex = arc4random() % 2 == 0 ? 1 : 2
        //设置User mobiles
        user.mobiles = NSOrderedSet(array: [mobile1,mobile2])
        do{
            //存储数据
            try context.save()
            userList.append(user)
            print("数据已添加...")
        }catch let error as NSError {
            print("数据添加失败:\(error.localizedDescription)")
        }
    }
    //查询所有数据
    func fetchAllUserList() {
        let context = self.getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: "User")
        do{
            let userLt = try context.executeFetchRequest(fetchRequest)
            if let users = userLt as? [User] {
                userList = users
                tblUserList.reloadData()
            }
        }catch {
            print("fetch data failed:\(error)")
        }
    }
    //修改用户名
    func updateUserName(oldName:String,newName:String) {
        let context = self.getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "name=%@", oldName)
        fetchRequest.predicate = predicate
        do{
            let userList = try context.executeFetchRequest(fetchRequest)
            if let users = userList as? [User] {
                for user in users {
                    user.name = newName
                }
                try context.save()
                print("\(users.count) data updated...")
            }else{
                print("no data need update...")
            }
        }catch {
            print("update data failed:\(error)")
        }
    }
    //删除用户
    func deleteAUser(objID:NSManagedObjectID) {
        let context = self.getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "SELF = %@", objID)
        fetchRequest.predicate = predicate
        do{
            let userList = try context.executeFetchRequest(fetchRequest)
            
            if let users = userList as? [User] {
                for user in users {
                    context.deleteObject(user)
                    user.objectID
                }
                try context.save()
                print("\(users.count) data deleted...")
            }else{
                print("no data need delete...")
            }
        }catch {
            print("delete data failed:\(error)")
        }
    }
    
    /*
    //MARK: Test
    // 不通过Model 的 插入 查询 删除 修改
    func insertNewData(userName:String,mobileName:String) {
        let context = self.getManagedObjectContext()
        //        NSManagedObject(entity: NSEntityDescription, insertIntoManagedObjectContext: NSManagedObjectContext?)
        let aUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context)
        aUser.setValue(userName, forKey: "name")
        aUser.setValue(1, forKey: "sex")
        aUser.setValue("天府大道北段", forKey: "address")
        do{
            try context.save()
        }catch{
            print("insert failed:\(error)")
        }
    }
    
    func fetchUserList(){
        let context = self.getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: "User")
        do{
            let userlist = try context.executeFetchRequest(fetchRequest)
            if let users = userlist as? [NSManagedObject] {
                for user in users {
                    print("Name:\(user.valueForKey("name")!)")
                    print("Sex:\(user.valueForKey("sex"))!")
                    print("Address:\(user.valueForKey("address"))!")
                }
            }
        }catch{
            print("fetch failed:\(error)")
        }
    }
    
    func deleteByUserName(userName:String) {
        let context = self.getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "name=%@",userName)
        fetchRequest.predicate = predicate
        do{
            let userList = try context.executeFetchRequest(fetchRequest)
            if let users = userList as? [NSManagedObject] {
                for user in users {
                    context.deleteObject(user)
                }
                try context.save()
            }
        }catch{
            print("delete failed:\(error)")
        }
    }
    
    func updateUserAddressByUserName(userName:String,address:String) {
        let context = self.getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "name=%@",userName)
        fetchRequest.predicate = predicate
        do{
            let userList = try context.executeFetchRequest(fetchRequest)
            if let users = userList as? [NSManagedObject] {
                for user in users {
                    user.setValue(address, forKey: "address")
                }
                try context.save()
            }
        }catch{
            print("delete failed:\(error)")
        }
    }
     */
    
    func getManagedObjectContext() -> NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        if (newCollection.verticalSizeClass == .Regular) {
            isPortrait = true
        }else{
            isPortrait = false
        }
        tblUserList.reloadData()
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if isPortrait {//竖屏
            cell = tableView.dequeueReusableCellWithIdentifier("CellID_P")
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "CellID_P")
            }

        }else{//横屏
           cell  = tableView.dequeueReusableCellWithIdentifier("CellID_L")
            if cell == nil {
                cell = UITableViewCell(style: .Value1, reuseIdentifier: "CellID_L")
            }
        }
        let user = userList[indexPath.row]
        cell?.textLabel?.text = "Name:\(user.name!)"
        let mobiles = user.mobiles
        var strM = "Mobiles:"
        for mobile in mobiles! {
            let m = mobile as! Mobile
            strM += "\(m.name!)-\(m.system!)|"
        }
        cell?.selectionStyle = .None
        cell?.detailTextLabel?.text = strM
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    //需改用户名操作
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = userList[indexPath.row]
        let alert = UIAlertController(title: "Update", message: "Update UserName", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.text = user.name
        }
        alert.addAction(UIAlertAction(title: "Update", style: .Default, handler: { (action) in
            let txtF1 = alert.textFields!.first
            if let text = txtF1?.text {
                if text == user.name {
                    print("无需更新...")
                }else{
                    self.showUpdateConotrol(user.name!,newName: (txtF1?.text)!)
                    user.name = text
                    self.tblUserList.reloadData()
                }
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    //删除某条用户数据
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let user = userList[indexPath.row]
            deleteAUser(user.objectID)
            userList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

