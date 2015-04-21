//
//  SettingsViewController.swift
//  SwiftDemo
//
//  Created by Root on 20/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate {

    var pickerContainer = UIView()
    var picker = UIDatePicker()
    var updatedProfilePicture = false
    var selecteProfilePicture = UIImage()
    
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var textfieldUserName: UITextField!
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var buttonDateOfBirth: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateUI()
        self.fillUserDetails()
        self.configurePicker()
        
        updatedProfilePicture = false
    }

    func updateUI()
    {
        var frame = self.view.frame
        
        frame   = self.scrollViewContainer.frame
        frame.size.height   = 200
        
        self.scrollViewContainer.frame  = CGRectMake(0.0, self.scrollViewContainer.frame.origin.y, 320.0, 447.0)
        
//        self.scrollViewContainer.hidden = true
        self.scrollViewContainer.contentSize    = CGSizeMake(320.0, 684.0)
    }
    
    func fillUserDetails()
    {
        let user = PFUser.currentUser() as PFUser
        
        self.textfieldUserName.text = user.username
        self.textfieldEmailAddress.text = user.email
//        self.textfieldPassword.text     = "ddd"
        
        let dob = user["dobstring"] as String
        
        self.buttonDateOfBirth.setTitle(dob, forState: UIControlState.Normal)

        let gender = user["gender"] as String
        
        var button1 = self.view.viewWithTag(1) as UIButton
        var button2 = self.view.viewWithTag(2) as UIButton
        
        if (gender == "male")
        {
            button1.selected    = true
            button2.selected    = false
        }
        else
        {
            button1.selected    = false
            button2.selected    = true
        }
        
        let interestedIn = user["interestedin"] as String
        
        button1 = self.view.viewWithTag(3) as UIButton
        button2 = self.view.viewWithTag(4) as UIButton
        
        if (interestedIn == "male")
        {
            button1.selected    = true
            button2.selected    = false
        }
        else
        {
            button1.selected    = false
            button2.selected    = true
        }
        
        var query = PFQuery(className: "UserPhoto")
        query.whereKey("user", equalTo: user)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated:true)
        query.findObjectsInBackgroundWithBlock{
            (NSArray objects, NSError error) -> Void in
            
            if(objects.count != 0)
            {
                let object = objects[objects.count - 1] as PFObject
                let theImage = object["imageData"] as PFFile
                println(theImage)
                
                if (theImage.isDataAvailable) {
                    let imageData:NSData    = theImage.getData()
                    let image               = UIImage(data: imageData)
                
                    self.profilePictureView.image   = image
                }
                /*
                var imageDownloadQueue = dispatch_queue_create("downloadimage", DISPATCH_QUEUE_PRIORITY_DEFAULT)
                
                dispatch_async(imageDownloadQueue, {
                    
                    let imageData:NSData    = theImage.getData()
                    let image               = UIImage(data: imageData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.profilePictureView.image   = image
                        })
                    })
                */
                
                
            }
            MBProgressHUD.hideHUDForView(self.view, animated:false)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chooseProfilePicture(sender: UIButton)
    {
        let myActionSheet = UIActionSheet()
        myActionSheet.delegate = self
        
        myActionSheet.addButtonWithTitle("Camera")
        myActionSheet.addButtonWithTitle("Photo Library")
        myActionSheet.addButtonWithTitle("Cancel")
        myActionSheet.cancelButtonIndex = 2
        
        myActionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int)
    {
        var sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        
        if (buttonIndex == 0)
        {
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) //Camera not available
            {
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            
            self.displayImagepicker(sourceType)
        }
        else if (buttonIndex == 1)
        {
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.displayImagepicker(sourceType)
        }
    }
    
    func displayImagepicker(sourceType:UIImagePickerControllerSourceType)
    {
        var imagePicker:UIImagePickerController = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        
        self.dismissViewControllerAnimated(true, completion: {
            
            var mediatype:NSString = info[UIImagePickerControllerMediaType]! as NSString
            
            if (mediatype == "public.image")
            {
                let originalImage = info[UIImagePickerControllerOriginalImage] as UIImage
                
                print("%@",originalImage.size)
                
                self.profilePictureView.image = self.resizeImage(originalImage, toSize: CGSizeMake(134.0, 144.0))
                
                self.selecteProfilePicture = self.resizeImage(originalImage, toSize: CGSizeMake(320.0, 480.0))
                
                self.updatedProfilePicture = true
            }
            
            })
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        if (alertView.tag == 10)
        {
            if(buttonIndex == 1)
            {
                FBSession.activeSession().closeAndClearTokenInformation()
                let user = PFUser.currentUser() as PFUser
                PFUser.logOut()
                self.tabBarController!.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        else
        {
            self.navigationController!.popToRootViewControllerAnimated(true)
        }
        
    }
    
    
    @IBAction func changeDateOfBirth(sender: AnyObject)
    {
        self.textfieldUserName.resignFirstResponder()
        self.textfieldEmailAddress.resignFirstResponder()
        self.textfieldPassword.resignFirstResponder()
        
        
        UIView.animateWithDuration(0.4, animations: {
            
            var frame:CGRect = self.pickerContainer.frame
            frame.origin.y = self.view.frame.size.height - 300.0 + 40
            self.pickerContainer.frame = frame
            
            })
    }
    
    @IBAction func selectGender(sender: UIButton)
    {
        if (sender.tag == 1)
        {
            sender.selected = true
            
            let female = self.view.viewWithTag(2) as UIButton
            
            female.selected = false
        }
        else if (sender.tag == 2)
        {
            sender.selected = true
            
            let male = self.view.viewWithTag(1) as UIButton
            
            male.selected = false
        }
    }
    
    @IBAction func interestedIn(sender: UIButton)
    {
        if (sender.tag == 3)
        {
            sender.selected = true
            
            let female = self.view.viewWithTag(4) as UIButton
            
            female.selected = false
        }
        else if (sender.tag == 4)
        {
            sender.selected = true
            
            let male = self.view.viewWithTag(3) as UIButton
            
            male.selected = false
        }
    }


    @IBAction func updateMyProfile(sender : UIButton)
    {
        if (checkMandatoryFieldsAreSet())
        {
            sender.enabled  = false
            
            var user = PFUser.currentUser()
            user.username   = self.textfieldUserName.text
            user.password   = self.textfieldPassword.text
            user.email      = self.textfieldEmailAddress.text
            
            let dateOfBirth = self.buttonDateOfBirth.titleForState(UIControlState.Normal)
            user["dobstring"] = dateOfBirth
            
            var button1 = self.view.viewWithTag(1) as UIButton
            var button2 = self.view.viewWithTag(2) as UIButton
            
            user["gender"] = button1.selected ? "male" : "female"
            
            button1 = self.view.viewWithTag(3) as UIButton
            button2 = self.view.viewWithTag(4) as UIButton
            
            user["interestedin"] = button1.selected ? "male" : "female"
            
            MBProgressHUD.showHUDAddedTo(self.view, animated:true)
            user.saveInBackgroundWithBlock(
            {
                (BOOL succeeded, NSError error) -> Void in
                
                if (error == nil)
                {
                    if (self.updatedProfilePicture)
                    {
                        let imageName = self.textfieldUserName.text + ".jpg" as String
                    
                        let userPhoto = PFObject(className: "UserPhoto")
                    
                        let imageData = UIImagePNGRepresentation(self.selecteProfilePicture)
                    
                        let imageFile = PFFile(name:imageName, data:imageData)
                    
                        userPhoto["imageFile"] = imageName
                    
                        userPhoto["imageData"] = imageFile
                    
                        userPhoto["user"] = user
                    
                        userPhoto.saveInBackgroundWithBlock{
                        
                        (succeeded:Bool!, error:NSError!) -> Void in
                        
                        if (error != nil)
                        {
                            var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Successfully updated profile.", delegate: nil, cancelButtonTitle: "Ok")
                            
                            alert.show()
                            
                            
                        }
                        else
                        {
//                            if let errorString = error.userInfo["error"]? as NSString
//                            {
//                                println(errorString)
//                            }
                        }

                        sender.enabled  = true
                        MBProgressHUD.hideHUDForView(self.view, animated:false)
                    }
                    
                    self.updatedProfilePicture = false
                    }
else
                    {
                        var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Successfully updated profile.", delegate: nil, cancelButtonTitle: "Ok")
                            
                        alert.show()

                        sender.enabled  = true
                        MBProgressHUD.hideHUDForView(self.view, animated:false)
                    }
                    
                }
                
            })
//            user.signUpInBackgroundWithBlock {
            
                /*
                (succeeded: Bool!, error: NSError!) -> Void in
                if !error
                {
                    let imageName = self.userName + ".jpg" as String
                    
                    let userPhoto = PFObject(className: "UserPhoto")
                    
                    let imageData = UIImagePNGRepresentation(self.selecteProfilePicture)
                    
                    let imageFile = PFFile(name:imageName, data:imageData)
                    
                    userPhoto["imageFile"] = imageName
                    
                    userPhoto["imageData"] = imageFile
                    
                    userPhoto["user"] = user
                    
                    
                    userPhoto.saveInBackgroundWithBlock{
                        
                        (succeeded:Bool!, error:NSError!) -> Void in
                        
                        if !error
                        {
                            var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Successfully Signed Up. Please login using your Email address and Password.", delegate: self, cancelButtonTitle: "Ok")
                            
                            alert.show()
                        }
                        else
                        {
//                            if let errorString = error.userInfo["error"] as NSString
//                            {
//                                println(errorString)
//                            }
                        }
                    }
                }
                else
                {
                    if let errorString = error.userInfo["error"] as NSString
                    {
                        println(errorString)
                    }
                }
                
                */
            }
        
    }
    
    @IBAction func logOutUser(sender: UIButton)
    {

        var alert:UIAlertView = UIAlertView(title: "Message", message: "Are you sure want to logout", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
            
        alert.tag = 10

        alert.show()
    }
    
    
    func configurePicker()
    {
        pickerContainer.frame = CGRectMake(0.0, 600.0, 320.0, 300.0)
        pickerContainer.backgroundColor = UIColor.whiteColor()
        
        picker.frame    = CGRectMake(0.0, 20.0, 320.0, 300.0)
        picker.setDate(NSDate(), animated: true)
        picker.maximumDate = NSDate()
        picker.datePickerMode = UIDatePickerMode.Date
        pickerContainer.addSubview(picker)
        
        var doneButton = UIButton()
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: Selector("dismissPicker"), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.frame    = CGRectMake(250.0, 5.0, 70.0, 37.0)
        
        pickerContainer.addSubview(doneButton)
        
        self.view.addSubview(pickerContainer)
    }
    
    func dismissPicker ()
    {
        UIView.animateWithDuration(0.4, animations: {
            
            self.pickerContainer.frame = CGRectMake(0.0, 600.0, 320.0, 300.0)
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            self.buttonDateOfBirth.setTitle(dateFormatter.stringFromDate(self.picker.date), forState: UIControlState.Normal)
            })
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func checkMandatoryFieldsAreSet() -> Bool
    {
        var allFieldsAreSet = true
        
        var message = ""
        
        var button1 = self.view.viewWithTag(1) as UIButton
        var button2 = self.view.viewWithTag(2) as UIButton
        
        if (!button1.selected && !button2.selected)
        {
            message = "Please select your gender"
        }
        
        button1 = self.view.viewWithTag(3) as UIButton
        button2 = self.view.viewWithTag(4) as UIButton
        
        if (!button1.selected && !button2.selected)
        {
            message = "Please select whether you are interested in girls or boys"
        }
        
        if (message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0)
        {
            var alert:UIAlertView = UIAlertView(title: "Message", message: message, delegate: nil, cancelButtonTitle: "Ok")
            
            alert.show()
            
            allFieldsAreSet = false
        }
        
        return allFieldsAreSet
    }

    func resizeImage(original : UIImage, toSize size:CGSize) -> UIImage
    {
        var imageSize:CGSize = CGSizeZero
        
        if (original.size.width < original.size.height)
        {
            imageSize.height    = size.width * original.size.height / original.size.width
            imageSize.width     = size.width
        }
        else
        {
            imageSize.height    = size.height
            imageSize.width     = size.height * original.size.width / original.size.height
        }
        
        UIGraphicsBeginImageContext(imageSize)
        original.drawInRect(CGRectMake(0,0,imageSize.width,imageSize.height))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    //386
    //460
    //564
}
