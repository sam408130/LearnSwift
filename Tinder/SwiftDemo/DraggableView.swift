//
//  DraggableView.swift
//  SwiftDemo
//
//  Created by Root on 23/08/14.
//  Copyright (c) 2014 Root. All rights reserved.
//

let ACTION_MARGIN:CGFloat   = 80 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH  = 4 //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:CGFloat       = 0.93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX:CGFloat    = 1.0 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH:CGFloat   = 320.0 //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE  = M_PI/8 //%%% Higher = stronger rotation angle

import UIKit

class DraggableView: UIView, UIGestureRecognizerDelegate {

    var profileImagView = UIImageView()
    var pangesture      = UIPanGestureRecognizer()
    var xFromCenter:CGFloat = 0.0
    var yFromCenter:CGFloat = 0.0
    var originalPoint:CGPoint   = CGPointMake(0.0, 0.0)
    var labelNameAndAge = UILabel()
    
    var delegate:ProfileSelectorViewController?
    var user:PFUser?
    
    init(frame: CGRect, delegate:AnyObject) {
        super.init(frame: frame)
        // Initialization code
        
        self.delegate   = (delegate as ProfileSelectorViewController)
        
        self.profileImagView.frame = self.bounds
        
        self.addSubview(self.profileImagView)
        
        self.pangesture = UIPanGestureRecognizer(target: self, action: Selector("dragging:"))
        
        self.addGestureRecognizer(pangesture)
        
        var backgroundView              = UIView(frame: CGRectMake(0.0, self.profileImagView.frame.size.height - 50.0, self.profileImagView.frame.size.width, 50.0)) as UIView
        backgroundView.backgroundColor  = UIColor.blackColor()
        backgroundView.alpha            = 0.5
        
        self.labelNameAndAge                    = UILabel(frame: CGRectMake(10.0, self.profileImagView.frame.size.height - 50.0, self.profileImagView.frame.size.width - 10, 50.0))
        self.labelNameAndAge.backgroundColor    = UIColor.clearColor()
        self.labelNameAndAge.textColor          = UIColor.whiteColor()
//        self.labelNameAndAge.alpha              = 0.5
        self.labelNameAndAge.numberOfLines = 0;
        self.labelNameAndAge.text = "rr"
        
        self.addSubview(backgroundView)
        self.addSubview(self.labelNameAndAge)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUser(newUser:PFUser)
    {
        self.user   = newUser
    }
    
    func update() {
        let user:PFUser = self.user! as PFUser
        
        let dateOfBirth = self.calculateAge(user["dobstring"] as String)
        
        let location:PFGeoPoint = user["location"] as PFGeoPoint
        var coreLocationPoint:CLLocation    = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        var distance = NSNumber(int: -1)
        distance = GlobalVariableSharedInstance.findDistance( location ) as NSNumber
        var distanceString  = NSString(format: "%d m", Int(distance))
        if Int(distance)/1000 > 0     //conver to kilometer
        {
            distanceString  = NSString(format: "%d Km", Int(distance)/1000)
        }
        self.setProfileDescription(Name: user.username + ", \(dateOfBirth)", andPlace: "", andDistance:distanceString)
        
        var query = PFQuery(className: "UserPhoto")
        query.whereKey("user", equalTo: user)
        
        MBProgressHUD.showHUDAddedTo(self, animated:true)
        query.findObjectsInBackgroundWithBlock{
            (NSArray objects, NSError error) -> Void in
            
            if(objects.count != 0)
            {
                let object = objects[objects.count - 1] as PFObject
                let theImage = object["imageData"] as PFFile
                
                let imageData:NSData    = theImage.getData()
                let image               = UIImage(data: imageData)
                
                self.profileImagView.image  = image
            }
            MBProgressHUD.hideHUDForView(self, animated:false)
        }
        
        MBProgressHUD.showHUDAddedTo(self, animated:true)
        CLGeocoder().reverseGeocodeLocation(coreLocationPoint, completionHandler:
            {(placemarks, error) in
                if error != nil {
                    println("reverse geodcode fail: \(error.localizedDescription)")
                }
                else {
                    let pm = placemarks as [CLPlacemark]
                    if pm.count > 0
                    {
                        let placeMark = placemarks[0] as CLPlacemark
                        
                        self.setProfileDescription(Name: user.username + ", \(dateOfBirth)", andPlace: placeMark.locality, andDistance:distanceString)
                    }
                }
                MBProgressHUD.hideHUDForView(self, animated:false)
            })
    }
    
    func setProfileDescription(Name name:String, andPlace place:String, andDistance distance:String)
    {
        var description = name;
        var location:String = place
        if (location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0) {
            location = location + ", " + distance
        }
        if (location.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 ) {
            description = name + "\n" + location
        }
        self.labelNameAndAge.text   = description
    }
    
    func calculateAge(dobString:String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat    = "dd/MM/yyyy"
        
        var date    = dateFormatter.dateFromString(dobString)! as NSDate
        var timeInterval    = date.timeIntervalSinceNow
        
        let age = Int(abs(timeInterval / (60 * 60 * 24 * 365))) as Int

        return String(age)
    }
    
    func dragging(gesture :UIPanGestureRecognizer)
    {
        xFromCenter = gesture.translationInView(self).x //%%% positive for right swipe, negative for left
        yFromCenter = gesture.translationInView(self).y //%%% positive for up, negative for down
        
        switch (gesture.state) {
        case UIGestureRecognizerState.Began:
            self.originalPoint = self.center

        case UIGestureRecognizerState.Changed:
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            let rotationStrength:CGFloat = min(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            let rotationAngel:CGFloat = (CGFloat) (CGFloat(ROTATION_ANGLE) * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            let scale:CGFloat = max(1 - CGFloat(fabsf(Float(rotationStrength))) / CGFloat(SCALE_STRENGTH), SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            let transform:CGAffineTransform  = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            let scaleTransform:CGAffineTransform  = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
//            [self updateOverlay:xFromCenter];
            
        case UIGestureRecognizerState.Ended:
            afterSwipeAction()
//        case UIGestureRecognizerStatePossible:break;
//        case UIGestureRecognizerStateCancelled:break;
//        case UIGestureRecognizerStateFailed:break;
            default:
            println("finished swiping")
    }
    }

    func afterSwipeAction()
    {
        if (self.xFromCenter > ACTION_MARGIN)
        {
            self.rightAction()
        }
        else if (xFromCenter < -ACTION_MARGIN)
        {
            self.leftAction()
        }
        else
        {
            UIView.animateWithDuration(0.15, animations:
                {
                    self.center = self.originalPoint
                    self.transform = CGAffineTransformMakeRotation(0)
                })
        }
    }


    func rightAction()
    {
        let finishPoint:CGPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y)
        
        UIView.animateWithDuration(0.15, animations:
            {
                self.center = finishPoint
            })
        
        delegate?.cardSwipedRight(self)
//        [delegate cardSwipedRight:self];
        
        NSLog("YES");
    }

//%%% called when a swip exceeds the ACTION_MARGIN to the left
    func leftAction()
    {
        let finishPoint:CGPoint = CGPointMake(-500, 2 * yFromCenter + self.originalPoint.y);
        
        UIView.animateWithDuration(0.15, animations:
            {
                self.center = finishPoint
            })
        
        delegate?.cardSwipedLeft(self)
//        [delegate cardSwipedLeft:self];
        
        NSLog("NO");
}

    func getUserName() -> String
    {
        return labelNameAndAge.text!.componentsSeparatedByString(",")[0]
    }
    
    func setProfileImage(image:UIImage)
    {
        self.profileImagView.image = image
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
