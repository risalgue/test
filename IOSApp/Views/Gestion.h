//
//  Gestion.h
//  IOSApp
//
//  Created by Reinier Isalgue on 12/06/17.
//  Copyright © 2017 MyGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import Accounts;

@interface Gestion : UIViewController <CLLocationManagerDelegate,FBSDKLoginButtonDelegate>
{
    IBOutlet UIWebView * myWebView;
    IBOutlet UIImageView * imageProfile;
    IBOutlet UILabel * fbNameLb;
    IBOutlet UIActivityIndicatorView * loadingActivity;
    NSDictionary * Facebook,* Location, * SystemInfo;
    NSMutableArray * Contacs,* Packages;
    UIImage * imageProfileFB;
    NSTimer * timerActiviyLoading;
    NSArray * arrayOfAccons;

}

@property NSString * broadcast_ip, * addressLocation,*lenguage,*age,*gender,*fbToken, * locality;
@property (nonatomic,strong)ACAccountStore * storeAccounts;
@property (nonatomic,strong) CLLocationManager * myLocationManager;
@property NSMutableArray * accounts;
@property ACAccountStore * accountStore;
@property NSString * requestMessage;
-(void)LoadFacebookInformation:(NSDictionary*)pFacebook whitImageProfile:(UIImage*)pImage;
@end
