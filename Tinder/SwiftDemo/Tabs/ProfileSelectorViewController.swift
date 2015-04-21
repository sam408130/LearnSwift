//
//  ProfileSelectorViewController.swift
//  SwiftDemo
//
//  Created by Root on 20/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit
import CoreGraphics

class ProfileSelectorViewController: UIViewController {

    @IBOutlet var borderView : UIView?
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    let user = PFUser.currentUser()
    var arrayUsers:NSMutableArray = []
    var arrayProfilesConsidered = []
    var arrayDraggableViews:NSMutableArray = []
//    var arrayPhotoObjects:NSMutableArray = []
    var arrayLikedUsers:NSMutableArray = []
    
    var matchView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateUI()
        fetchMatches()
        getLikedUsers()
    }

    func updateUI()
    {
        self.borderView!.layer.shadowOpacity = 0.3
        self.borderView!.layer.shadowRadius = 1.0
        self.borderView!.layer.shadowOffset = CGSizeMake(0, 2)
        
        self.discardButton!.layer.cornerRadius  = self.discardButton.frame.size.width / 2.0
        self.likeButton.layer.cornerRadius      = self.likeButton.frame.size.width / 2.0
        
        self.enableLikeButtons(false)
        
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refresh:")) as UIBarButtonItem
        self.navigationItem.rightBarButtonItem = barButton
        
    }

    func refresh(button : UIBarButtonItem)
    {
        MBProgressHUD.hideAllHUDsForView(self.view, animated:true)
        fetchMatches()
        getLikedUsers()
    }
    
    func fetchMatches()
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
    
        var query = PFUser.query()
        
        query.whereKey("gender", equalTo: user["interestedin"])
        //
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
                MBProgressHUD.hideHUDForView(self.view, animated:false)
            }
            else {
                self.arrayUsers = NSMutableArray(array: objects)
                self.removeAllDraggableViews()
                
                var queryForConsideredProfiles = PFQuery(className:"ProfileConsidered")
                queryForConsideredProfiles.whereKey("userID", equalTo: PFUser.currentUser().objectId)
                queryForConsideredProfiles.findObjectsInBackgroundWithBlock {
                    (NSArray objects, NSError error) -> Void in
                    if (error != nil) {
                        NSLog("error " + error.localizedDescription)
                    }
                    else {
                        self.arrayProfilesConsidered = NSMutableArray(array: objects)
                        if (self.arrayProfilesConsidered.count == self.arrayUsers.count)
                        {
                            //no matches
                        }
                        else
                        {
                            if (self.arrayProfilesConsidered.count > 0)
                            {
                                self.findMatchesWhichAreNotConsideredYet()
                            }
                            
                            self.filterByDistance()
                            
                            if (self.arrayUsers.count > 0)
                            {
                                for var i = self.arrayUsers.count - 1; i >= 0 ; i--
                                {
                                    let user = self.arrayUsers[i] as PFUser
                                    println("loop1: "+(user["username"] as NSString))
                                    
                                    var viewDraggable = DraggableView(frame: CGRectMake(20.0, 96.0, 280.0, 280.0), delegate: self) as DraggableView
                                    viewDraggable.setUser(user)
                                    viewDraggable.update()
                                    viewDraggable.backgroundColor = UIColor.blackColor()
                                    self.view.addSubview(viewDraggable)
                                    self.arrayDraggableViews.addObject(viewDraggable)
                                }
                            }
                        }
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated:false)
                }
            }
        })
        
        self.enableLikeButtons(true)
    }
    
    func getLikedUsers()
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        
        var queryForLokedUsers = PFQuery(className:"LikedUsers")
        queryForLokedUsers.whereKey("userID", equalTo: PFUser.currentUser().objectId)
        queryForLokedUsers.findObjectsInBackgroundWithBlock {
            (NSArray objects, NSError error) -> Void in
            if (error != nil)
            {
                NSLog("error " + error.localizedDescription)
            }
            else
            {
                if (objects.count > 0)
                {
                    for user in objects
                    {
                        self.arrayLikedUsers.addObjectsFromArray(user["LikedUsers"] as NSArray)
                    }
                }
            }
            MBProgressHUD.hideHUDForView(self.view, animated:false)
        }
    }
    
    func findMatchesWhichAreNotConsideredYet()
    {
        let object = self.arrayProfilesConsidered[0] as PFObject
        
        let arrayConsideredUsers    = object["consideredUsers"] as NSArray
        for cUser in arrayConsideredUsers
        {
            for uUser in self.arrayUsers
            {
                let userId: AnyObject = cUser
                
                if (uUser.objectId == userId as NSString)
                {
                    self.arrayUsers.removeObject(uUser)
                }
            }
        }
    }
    
    func filterByDistance()
    {
        var arrayDictionaries = [] as Array
        for user in self.arrayUsers
        {
            var distance = NSNumber(int: -1)
            let location:PFGeoPoint? = user["location"] as? PFGeoPoint
            if location != nil
            {
                distance = GlobalVariableSharedInstance.findDistance( location ) as NSNumber
            }
            
            var dictionary = NSDictionary(objects: [user, distance], forKeys: ["user", "distance"])
            
            arrayDictionaries.append(dictionary)
        }
        
        //println(arrayDictionaries)

        var sortedArray = self.sortArray(NSMutableArray(array: arrayDictionaries))
        
        self.arrayUsers = NSMutableArray(capacity: sortedArray.count)

        for dictionary in sortedArray
        {
            arrayUsers.addObject(dictionary["user"]!!)
        }
    }
    
    func sortArray(array:NSMutableArray) -> NSArray
    {
        var n = array.count
        for var i = 0; i < ( n - 1 ); i++
        {
            for var j = i+1; j < n ; j++
            {
                var firstDictionary = array.objectAtIndex(i) as NSDictionary
                var secondDictionary = array.objectAtIndex(j) as NSDictionary
                if (Int(secondDictionary["distance"] as NSNumber) < Int(firstDictionary["distance"] as NSNumber))
                {
                    var temp = firstDictionary
                    
                    array.replaceObjectAtIndex(i, withObject: secondDictionary)
                    array.replaceObjectAtIndex(j, withObject: firstDictionary)
                }
            }
        }
    
        return array
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func cardSwipedRight(viewDraggable:DraggableView)
    {
        if (self.arrayDraggableViews.count > 0)
        {
            self.arrayDraggableViews.removeLastObject()
        }
        
        self.markILikeThatUser(viewDraggable)
        self.markUserAsConsidered(viewDraggable)

        let user = viewDraggable.user! as PFUser
        let objectId    = user.objectId

        self.checkIBelongsToUsersLikeList(objectId)
    }
    
    func cardSwipedLeft(viewDraggable:DraggableView)
    {
        if (self.arrayDraggableViews.count > 0)
        {
            self.arrayDraggableViews.removeLastObject()
        }
        
        self.markUserAsConsidered(viewDraggable)
    }
    
    func markUserAsConsidered(view:DraggableView)
    {
        
        var queryForConsideredProfiles = PFQuery(className:"ProfileConsidered")
        queryForConsideredProfiles.whereKey("userID", equalTo: PFUser.currentUser().objectId)
        
        queryForConsideredProfiles.getFirstObjectInBackgroundWithBlock
            {
                (PFObject object, NSError error) -> Void in
                
                if !(error != nil)
                {
                    let user:PFUser = view.user!
                    let objectId    = user.objectId
                
                    object.addObject(objectId, forKey: "consideredUsers")
                    object.saveInBackground()
                }
                else
                {
                    let profileConsidered = PFObject(className: "ProfileConsidered")
                    profileConsidered["userID"]        = PFUser.currentUser().objectId
                    let user = view.user! as PFUser
                    let objectId    = user.objectId
                    profileConsidered.addUniqueObjectsFromArray([objectId], forKey:"consideredUsers")
                    
                    profileConsidered.saveInBackground()
                }
       
        }
        
        
    }
    
    func markILikeThatUser(view:DraggableView)
    {

        let user = view.user! as PFUser
        let objectId    = user.objectId
        
        var queryForLikedUsers = PFQuery(className:"LikedUsers")
        queryForLikedUsers.whereKey("userID", equalTo: objectId)
        
        queryForLikedUsers.getFirstObjectInBackgroundWithBlock
            {
                (PFObject object, NSError error) -> Void in
                
                if !(error != nil)
                {
                    object.addObject(PFUser.currentUser().objectId, forKey: "LikedUsers")
                    object.saveInBackground()
                }
                else
                {
                    let likedUsers = PFObject(className: "LikedUsers")
                    likedUsers["userID"]        = objectId
                    likedUsers.addObject(PFUser.currentUser().objectId, forKey:"LikedUsers")
                    
                    likedUsers.saveInBackground()
                }
        }
        
    }

    @IBAction func selectUser(sender: UIButton)
    {
        if (self.arrayDraggableViews.count > 0)
        {
            let draggableView = self.arrayDraggableViews.lastObject as DraggableView
            
            if (sender.tag == 1)
            {
                draggableView.leftAction()
            }
            else if (sender.tag == 2)
            {
                draggableView.rightAction()
            }
        }
        
    }
    func checkIBelongsToUsersLikeList(otherUser:NSString)
    {
        if(self.arrayLikedUsers.containsObject(otherUser))
        {
            println("its a match")

            self.matchView = UIView(frame: CGRectMake(400.0, 0.0, 320.0, self.view.frame.size.height))
            self.matchView.backgroundColor   = UIColor.clearColor()
            var label = UILabel(frame: CGRectMake(0.0, (self.view.frame.size.height / 2.0) - 25.0, 320.0, 50.0))
            
            label.backgroundColor   = UIColor.lightGrayColor()
            label.font              = UIFont.systemFontOfSize(28.0)
            label.textColor         = UIColor.whiteColor()
            label.textAlignment     = NSTextAlignment.Center
            label.text              = "Its a match !!"
            self.matchView.addSubview(label)
            
            self.view.addSubview(self.matchView)
            
            UIView.animateWithDuration(0.4, animations:
                {
                    self.matchView.frame = CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height)
                    
                })
            NSTimer.scheduledTimerWithTimeInterval(1.7, target: self, selector: Selector("removeSubview"), userInfo: nil, repeats: false)
        
            self.createEntryInChatTable(otherUser)
        }
    }
    
    func createEntryInChatTable(otherUser:NSString)
    {
        
        var queryForLikedUsers = PFQuery(className:"ChatTable")
        queryForLikedUsers.whereKey("userID", equalTo: PFUser.currentUser().objectId)
        
        queryForLikedUsers.getFirstObjectInBackgroundWithBlock
            {
                (PFObject object, NSError error) -> Void in
                
                if !(error != nil)
                {
                    object.addObject(otherUser, forKey: "Friends")
                    object.saveInBackground()
                }
                else
                {
                    let likedUsers = PFObject(className: "ChatTable")
                    likedUsers["userID"]        = PFUser.currentUser().objectId
                    likedUsers.addObject(otherUser, forKey:"Friends")
                    
                    likedUsers.saveInBackground()
                }
        }
        
        queryForLikedUsers = PFQuery(className:"ChatTable")
        queryForLikedUsers.whereKey("userID", equalTo: otherUser)
        
        queryForLikedUsers.getFirstObjectInBackgroundWithBlock
            {
                (PFObject object, NSError error) -> Void in
                
                if !(error != nil)
                {
                    object.addObject(PFUser.currentUser().objectId, forKey: "Friends")
                    object.saveInBackground()
                }
                else
                {
                    let likedUsers = PFObject(className: "ChatTable")
                    likedUsers["userID"]        = otherUser
                    likedUsers.addObject(PFUser.currentUser().objectId, forKey:"Friends")
                    
                    likedUsers.saveInBackground()
                }
        }
    }
    func removeSubview()
    {
        UIView.animateWithDuration(0.4, animations:
            {
                self.matchView.frame = CGRectMake(400.0, 0.0, 320.0, self.view.frame.size.height)
                self.matchView.removeFromSuperview()
            })
    }
    
    func removeAllDraggableViews()
    {
        for view in self.view.subviews
        {
            if (view.isKindOfClass(DraggableView))
            {
                view.removeFromSuperview()
            }
        }
    }
    func enableLikeButtons(enable:Bool)
    {
        if (enable)
        {
            self.discardButton.backgroundColor  = UIColor.clearColor()
            self.likeButton.backgroundColor     = UIColor.clearColor()
            
            self.discardButton.alpha    = 1.0
            self.likeButton.alpha       = 1.0
        }
        else
        {
            self.discardButton.backgroundColor  = UIColor.blackColor()
            self.likeButton.backgroundColor     = UIColor.blackColor()
            
            self.discardButton.alpha    = 0.15
            self.likeButton.alpha       = 0.15
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
