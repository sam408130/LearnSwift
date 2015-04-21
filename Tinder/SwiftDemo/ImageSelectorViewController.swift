//
//  ImageSelectorViewController.swift
//  SwiftDemo
//
//  Created by Root on 19/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

import UIKit

class ImageSelectorViewController: UIViewController, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    var profilePictureView:FBProfilePictureView = FBProfilePictureView()
    var loginScreen:ViewController?

    var userName = ""
    var password = ""
    var emailID  = ""
    var dateOfBirth = ""
    var facebookLogin = false
    var selecteProfilePicture = UIImage()
    var user: FBGraphUser!
    var selectedImage:Bool  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        if (user != nil) {
            //profilePictureView.profileID = user.id
/*for view in profilePictureView.subviews {
   if let imgView = view as? UIImageView {
        let img : UIImage = imgView.image
        if (img != nil) {
            setProfileImage(img);
            break
        }
   }
   else {
      // obj is not a String
   }
}*/
            let str = NSString(format:"https://graph.facebook.com/%@/picture?type=large", user.id)
            let url = NSURL.URLWithString(str);
            var err: NSError? = NSError()
            var imageData :NSData = NSData.dataWithContentsOfURL(url,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
            var bgImage = UIImage(data:imageData)
            setProfileImage(bgImage)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUserName(name:String, password:String, Email email:String, andDateOfBirth dob:String)
    {
        self.userName       = name
        self.emailID        = email
        self.password       = password
        self.dateOfBirth    = dob
        
        println(self.password)
    }
    
    @IBAction func signUpTapped(sender: UIButton)
    {
        if (checkMandatoryFieldsAreSet())
        {
            var user = PFUser()
            user.username   = self.userName
            user.password   = self.password
            user.email      = self.emailID
           
            user["dobstring"] = self.dateOfBirth
            
            var button1 = self.view.viewWithTag(1) as UIButton
            var button2 = self.view.viewWithTag(2) as UIButton
            
            user["gender"] = button1.selected ? "male" : "female"
            
            button1 = self.view.viewWithTag(3) as UIButton
            button2 = self.view.viewWithTag(4) as UIButton
            
            user["interestedin"] = button1.selected ? "male" : "female"
            
            var location:CLLocation = CLLocation()
            
            location = GlobalVariableSharedInstance.currentLocation() as CLLocation
            
            let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) as PFGeoPoint
            
            user["location"] = geoPoint
            
            if (facebookLogin == true)
            {
                user["fbID"] =  self.user.id
            }

            MBProgressHUD.showHUDAddedTo(self.view, animated:true)
            user.signUpInBackgroundWithBlock {
                
                (succeeded: Bool!, error: NSError!) -> Void in
                if !(error != nil)
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
                        
                        MBProgressHUD.hideHUDForView(self.view, animated:false)
                        if !(error != nil)
                        {
                            var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Successfully Signed Up. Please login using your Email address and Password.", delegate: self, cancelButtonTitle: "Ok")
                            
                            alert.show()
                        }
                        else
                        {
                            if let errorString = error.userInfo?["error"] as? NSString
                            {
                                println(errorString)
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                            else {
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Unable to signup.", delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                        }
                    }
                }
                else
                {
                            if let errorString = error.userInfo?["error"] as? NSString
                            {
                                println(errorString)
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                            else {
                                var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Unable to signup.", delegate: nil, cancelButtonTitle: "Ok")
                            
                                alert.show()
                            }
                    MBProgressHUD.hideHUDForView(self.view, animated:false)                    
                }
            }
        }
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
                self.setProfileImage(originalImage);
            }
            
        })
        
    }

    func setProfileImage(originalImage: UIImage) {
        
        self.profilePicture.image = self.resizeImage(originalImage, toSize: CGSizeMake(134.0, 144.0))
        
        self.selecteProfilePicture = self.resizeImage(originalImage, toSize: CGSizeMake(320.0, 480.0))
        
        self.selectedImage  = true
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.selectedImage  = false
    }
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        var username = self.userName
        var pwd = self.password
        
        PFUser.logInWithUsernameInBackground(username , password:pwd){
            (user: PFUser!, error: NSError!) -> Void in
            if (user != nil)
            {
                if (self.facebookLogin == true)
                {
                    self.navigationController!.popToRootViewControllerAnimated(true)
                    //self.dismissViewControllerAnimated(false, completion: nil)
                }
                else
                {
                    let loginScreen = self.navigationController!.viewControllers![0] as ViewController
                    loginScreen.facebookLogin   = true
                    self.navigationController!.popToRootViewControllerAnimated(true)
                }
            }
            else
            {
                if let errorString = error.userInfo?["error"] as? NSString
                {
                    var alert:UIAlertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                    
                    alert.show()
                }
            }
        }
        
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
        
        if (self.selectedImage == false)
        {
            message = "Please select your profile picture"
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

}
