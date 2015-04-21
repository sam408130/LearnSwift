//
//  ChatViewController.swift
//  SwiftDemo
//
//  Created by Root on 20/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var arrayUserIds:NSArray = []
    var arrayFriends:NSMutableArray = []
//    var users:NSArray   = []
    var arrayUserFriends:NSMutableArray = []
    @IBOutlet weak var chatTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchFriends()
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refresh:")) as UIBarButtonItem
        self.navigationItem.rightBarButtonItem = barButton
    }

    func refresh(button : UIBarButtonItem)
    {
        self.arrayFriends.removeAllObjects()
        self.chatTable.reloadData()
        fetchFriends()
    }
    
    
    func fetchFriends()
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)

        var queryForConsideredProfiles = PFQuery(className:"ChatTable")
        queryForConsideredProfiles.whereKey("userID", equalTo: PFUser.currentUser().objectId)
        
        queryForConsideredProfiles.findObjectsInBackgroundWithBlock{
            (NSArray objects, NSError error) -> Void in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
                MBProgressHUD.hideHUDForView(self.view, animated:false)
            }
            else
            {
                if (objects.count > 0)
                {
                    var chatTableObject = objects[0] as PFObject
                    self.arrayUserIds   = chatTableObject["Friends"] as NSArray
                    
                    var userQuery = PFUser.query()
                    
                    userQuery.findObjectsInBackgroundWithBlock{
                        (NSArray objects, NSError error) -> Void in
                        
                        if (error != nil) {
                            NSLog("error " + error.localizedDescription)
                        }
                        else
                        {
                            let users = objects
                            
                            for userId in self.arrayUserIds
                            {
                                let user = self.getUserFromUserId(userId as String, arrayUsers: users)
                                
                                self.arrayUserFriends.addObject(user)
                                
                                var query = PFQuery(className: "UserPhoto")
                                query.whereKey("user", equalTo: user)
                                
                                query.findObjectsInBackgroundWithBlock{
                                    (NSArray objects, NSError error) -> Void in
                                    
                                    if(objects.count != 0)
                                    {
                                        let object = objects[objects.count - 1] as PFObject
                                        let theImage = object["imageData"] as PFFile
                                        
                                        let imageData:NSData    = theImage.getData()
                                        let image               = UIImage(data: imageData)
                                        
                                        let dictionary = NSDictionary(objects: [user.username, image], forKeys: ["username", "image"])
                                        
                                        self.arrayFriends.addObject(dictionary)
                                        
                                        self.chatTable.reloadData()
                                    }
                                }
                            }
                            
                        }
                        MBProgressHUD.hideHUDForView(self.view, animated:false)
                    }
                }
                else {
                    MBProgressHUD.hideHUDForView(self.view, animated:false)
                }
            }
        }
    }
    
    /*

    for var i = self.arrayUsers.count - 1; i >= 0 ; i--
    {
    let user = self.arrayUsers[i] as PFUser
    
    
    var query = PFQuery(className: "UserPhoto")
    query.whereKey("user", equalTo: user)
    
    query.findObjectsInBackgroundWithBlock{
    (NSArray objects, NSError error) -> Void in
    
    if(objects.count != 0)
    {
    self.removeAllDraggableViews()
    
    let object = objects[0] as PFObject
    let theImage = object["imageData"] as PFFile
    println(theImage)
    let imageData:NSData    = theImage.getData()
    let image               = UIImage(data: imageData)
    //
    
    var viewDraggable = DraggableView(frame: CGRectMake(20.0, 96.0, 280.0, 280.0), delegate: self) as DraggableView
    let dateOfBirth = self.calculateAge(user["dobstring"] as String)
    viewDraggable.setUser(user)
    println(dateOfBirth)
    viewDraggable.setProfilePicture(image, andName: user.username + ", \(dateOfBirth)")
    viewDraggable.backgroundColor = UIColor.blackColor()
    self.view.addSubview(viewDraggable)
    }
    }
    }
    
*/
    
    func getUserFromUserId(userID:String, arrayUsers:NSArray) -> PFUser
    {
        var requiredUser = PFUser()
        
        for aUser in arrayUsers
        {
            if (aUser.objectId == userID)
            {
                requiredUser = aUser as PFUser
                break
            }
        }
        
        return requiredUser
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if ((indexPath.row % 2) == 0)
        {
            cell.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        }
        else
        {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        let dictionary = self.arrayFriends.objectAtIndex(indexPath.row) as NSDictionary
   
        let username = dictionary.objectForKey("username") as String
        let image      = dictionary.objectForKey("image") as UIImage
        
        cell.textLabel!.text = username
        cell.imageView!.image    = image
        
        var bgColorView = UIView()
        // bgColorView.backgroundColor = UIColor(red: 76.0/255.0, green: 161.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        bgColorView.backgroundColor = UIColor(red: 0.78, green: 0.87, blue: 0.94, alpha: 1.0)
        bgColorView.layer.masksToBounds = true;
        cell.selectedBackgroundView = bgColorView;
        
        return cell
    }
    
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        return 54.0
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let messageController = storyboard.instantiateViewControllerWithIdentifier("MessagesViewController") as MessagesViewController
        
        let dictionary = self.arrayFriends.objectAtIndex(indexPath.row) as NSDictionary
        
        messageController.selectedUser  = self.arrayUserFriends.objectAtIndex(indexPath.row) as PFUser
        messageController.profileImage  = dictionary.objectForKey("image") as UIImage
        
        self.navigationController!.pushViewController(messageController, animated: true)
    }

}
