//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Root on 17/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBLoginViewDelegate,PFLogInViewControllerDelegate, UITextFieldDelegate {
    
//    var profilePictureView:FBProfilePictureView = FBProfilePictureView()
    var fbloginView:FBLoginView = FBLoginView()
    var facebookLogin:Bool  = false
    @IBOutlet weak var textfieldUserName: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        println("viewDidLoad");
        fbloginView.frame   = CGRectMake(60.0, 450.0, 200.0, 44.0)
        fbloginView.delegate = self
        /*fbloginView.readPermissions = ["email",
            "basic_info",
            "user_location",
            "user_birthday",
            "user_likes"]*/
        self.view.addSubview(fbloginView)
        
//        profilePictureView = FBProfilePictureView(frame: CGRectMake(70.0, fbloginView.frame.size.height + fbloginView.frame.origin.y, 180.0, 200.0))
//        self.view.addSubview(profilePictureView)
        
        GlobalVariableSharedInstance.initLocationManager()
    }

    override func viewWillAppear(animated: Bool)
    {
        println("viewWillAppear");
        //fbloginView.frame   = CGRectMake(60.0, 450.0, 200.0, 44.0)
        //profilePictureView.frame   = CGRectMake(70.0, 450.0, 180.0, 200.0)
        let user = PFUser.currentUser() as PFUser!
        if (user != nil)    //if (self.facebookLogin == true)//if (FBSession.activeSession().isOpen)
        {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("displayTabs"), userInfo: nil, repeats: false)
            self.facebookLogin  = false
        }
        else {
            FBSession.activeSession().closeAndClearTokenInformation()
        }
        
    }
    
    @IBAction func signIn(sender: UIButton)
    {
        
        println("signIn");
//        self.displayTabs()

        
        self.signInButton.enabled = false
        self.signUpButton.enabled = false
        
        var message = ""
        
        if (self.textfieldPassword.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "Password should not be empty"
        }
        
        if (self.textfieldUserName.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)
        {
            message = "User Name should not be empty"
        }
        
        if (message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0)
        {
            var alert:UIAlertView = UIAlertView(title: "Message", message: message, delegate: nil, cancelButtonTitle: "Ok")
            
            alert.show()
            
            self.signInButton.enabled = true
            self.signUpButton.enabled = true
        }
        
        else
        {
            MBProgressHUD.showHUDAddedTo(self.view, animated:true)
            PFUser.logInWithUsernameInBackground(self.textfieldUserName.text , password:self.textfieldPassword.text)
                {
                    (user: PFUser!, error: NSError!) -> Void in
                    if (user != nil)
                    {
                        self.displayTabs()
                    }
                    else
                    {
                        if let errorString = error.userInfo?["error"] as? NSString
                        {
                            var alert:UIAlertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                        
                            alert.show()
                        }
                        
                        
                    }
                    
                    self.signInButton.enabled = true
                    self.signUpButton.enabled = true

                    MBProgressHUD.hideHUDForView(self.view, animated:false)
            }
        }
        
    }

    override func viewWillLayoutSubviews()
    {
        super.viewWillAppear(false)
        //println("viewWillLayoutSubviews")
    }

    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!)
    {
        //self.profilePictureView.profileID = user.id
        
        println("loginViewFetchedUserInfo")
        var query = PFUser.query()
        
        query.whereKey("fbID", equalTo: user.id)
        //
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                MBProgressHUD.hideHUDForView(self.view, animated:false)
            }
            else{
                
                if (objects.count == 0)
                {
/*                    fbloginView.readPermissions = ["email"];
                    var me:FBRequest = FBRequest.requestForMe()
                    me.startWithCompletionHandler({(NSArray my, NSError error) in*/
                    println(user)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let imageUploaderView = storyboard.instantiateViewControllerWithIdentifier("ImageSelectorViewController") as ImageSelectorViewController
                    var email:String? = user.objectForKey("email") as String?
                    var birthday:String? = user.birthday
                    if (email==nil) {
                        email = user.first_name + "@user.com"
                    }
                    if (birthday==nil) {
                        birthday = "10/10/1987"
                    }
                    imageUploaderView.setUserName(user.name, password: user.id, Email: email!, andDateOfBirth: birthday!)
                    imageUploaderView.facebookLogin = true
                    self.facebookLogin  = true
                    imageUploaderView.user  = user
                    
                    MBProgressHUD.hideHUDForView(self.view, animated:false)
                    imageUploaderView.loginScreen = self;
                    self.navigationController!.pushViewController(imageUploaderView, animated: true)
                }
                else
                {
                    PFUser.logInWithUsernameInBackground(user.name , password:user.id)
                        {
                            (user: PFUser!, error: NSError!) -> Void in
                            if (user != nil)
                            {
                                /*
                                var alert:UIAlertView = UIAlertView(title: "Message", message: "Hi " + user.username + ". You logged in", delegate: nil, cancelButtonTitle: "Ok")
                                
                                alert.show()
                                */
                                
                                MBProgressHUD.hideHUDForView(self.view, animated:false)
                                self.displayTabs()
                            }
                            else
                            {
                                MBProgressHUD.hideHUDForView(self.view, animated:false)
                                if let errorString = error.userInfo?["error"] as? NSString
                                {
                                    var alert:UIAlertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                                    
                                    alert.show()
                                }
                            }
                            
                            self.signInButton.enabled = true
                            self.signUpButton.enabled = true
                    }
                }
            }
        })
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!)
    {
        println("loginViewShowingLoggedInUser")
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!)
    {
        println("loginViewShowingLoggedOutUser")
//        self.profilePictureView.profileID = nil
    }
    
    
    func displayTabs()
    {
        println("displayTabs")
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var tabbarController = UITabBarController()
        
        let profileSelectorViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileSelectorViewController") as ProfileSelectorViewController
        
        let chatViewController = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as ChatViewController
        
        let settingsViewController = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as SettingsViewController
        
        let profileSelectorNavigationController = UINavigationController(rootViewController: profileSelectorViewController)
        
        let chatNavigationController = UINavigationController(rootViewController: chatViewController)
        
        tabbarController.viewControllers = [ profileSelectorNavigationController, chatNavigationController, settingsViewController]
        
        var tabbarItem = tabbarController.tabBar.items![0] as UITabBarItem;
        tabbarItem.image    = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("groups", ofType: "png")!)
        tabbarItem.title    = nil
        
        tabbarItem = tabbarController.tabBar.items![1] as UITabBarItem;
        tabbarItem.image    = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("chat", ofType: "png")!)
        tabbarItem.title    = nil
        
        tabbarItem = tabbarController.tabBar.items![2] as UITabBarItem;
        tabbarItem.image    = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("settings", ofType: "png")!)
        tabbarItem.title    = nil
        
        //println(tabbarController.viewControllers)
        
        MBProgressHUD.hideHUDForView(self.view, animated:false)
        self.presentViewController(tabbarController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

