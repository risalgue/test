//
//  LoginView.h
//  IOSApp
//
//  Created by Reinier Isalgue on 15/06/17.
//  Copyright © 2017 MyGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface LoginView : UIViewController <FBSDKLoginButtonDelegate,CLLocationManagerDelegate>
{
    IBOutlet UIButton * Confirm;
    IBOutlet UISwitch * privacityPolit;
    IBOutlet UIView * parametersView;
    IBOutlet UITextField * age, * sex, * city, * email;
    IBOutlet UITextView * TittleLb;
    IBOutlet UIButton * polPrivLb;
    FBSDKLoginButton * facebookLoginBut;
    NSDictionary * Facebook;
}
@property MBProgressHUD * HUD;
@property NSString * requestMessage, * FBAccessToken;
@property UITapGestureRecognizer * gestureTap;
@property (nonatomic,strong) CLLocationManager * myLocationManager;
-(IBAction)goGestion:(id)sender;
-(IBAction)ShowPrivacyPolitical:(id)sender;
@end
