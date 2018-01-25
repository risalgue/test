//
//  LoginView.m
//  IOSApp
//
//  Created by Reinier Isalgue on 15/06/17.
//  Copyright © 2017 MyGroup. All rights reserved.
//

#import "LoginView.h"
#import "TSMessage.h"
#import "Gestion.h"

@interface LoginView ()

@end

@implementation LoginView

-(IBAction)goGestion:(id)sender{
    
    if ([age.text isEqualToString:@""]|| [city.text isEqualToString:@""] || [email.text isEqualToString:@""] || [sex.text isEqualToString:@""]) {
        _requestMessage = @"Missing values to fill";
        [self ShowError];
        [self shakeAnimation:parametersView];
    }
    else if (![self ValidateSex]){
        _requestMessage = @"Incorrect format to Sex, the correct format is M or F";
        [self ShowError];
    }
    else if(![self ValidateEmail]){
        _requestMessage = @"Incorrect email, please verify your email, example: user@gmail.com";
        [self ShowError];
    }
    else if (!privacityPolit.on){
        _requestMessage = @"Accept our Privacy Policy";
        [self ShowError];
    }
    else{
    Gestion * gestionView = [Gestion alloc];
    NSDictionary * Empty = @{@"Age" : age.text,
                             @"Email" : email.text,
                             @"Gender" : sex.text,
                             @"Locality" : city.text};
    
    [gestionView LoadFacebookInformation:Empty whitImageProfile:[UIImage imageNamed:@"ic_hdpi_launcher.png"]];
    [self.navigationController pushViewController:gestionView animated:YES];
    }
}
-(BOOL)ValidateEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate * emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email.text];
}
-(BOOL)ValidateSex
{
    if ([sex.text isEqualToString:@"M"]) {
        return YES;
    }
    else if([sex.text isEqualToString:@"F"]){
        return YES;
    }
    return NO;
}
-(void)shakeAnimation:(UIView*) view {
    const int reset = 5;
    const int maxShakes = 6;
    
    //pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 0;
    static int translate = reset;
    
    [UIView animateWithDuration:0.09-(shakes*.01) // reduce duration every shake from .09 to .04
                          delay:0.01f//edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                     animations:^{view.transform = CGAffineTransformMakeTranslation(translate, 0);}
                     completion:^(BOOL finished){
                         if(shakes < maxShakes){
                             shakes++;
                             
                             //throttle down movement
                             if (translate>0)
                                 translate--;
                             
                             //change direction
                             translate*=-1;
                             [self shakeAnimation:view];
                         } else {
                             view.transform = CGAffineTransformIdentity;
                             shakes = 0;//ready for next time
                             translate = reset;//ready for next time
                             return;
                         }
                     }];
}
-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSLog(@"Login whit Facebook delegate button");
    if ([result isCancelled]) {
        _requestMessage = @"Por favor acceda con su cuenta de Facebook";
        [self ShowError];
    }
    else if([FBSDKAccessToken currentAccessToken]){
        _HUD = [[MBProgressHUD alloc] init];
        _HUD.dimBackground = YES;
        _HUD.labelText = @"Cargando Datos de Facebook...";
        [self.view addSubview:_HUD];
        [_HUD show:YES];
        FBSDKGraphRequest * request = [[FBSDKGraphRequest alloc]
                                       initWithGraphPath:[NSString stringWithFormat:@"me"]
                                       parameters:@{@"fields" : @"id,name,link,locale,first_name,last_name,email,gender,birthday,picture.width(100).height(100)"}
                                       HTTPMethod:@"GET"];
        _FBAccessToken = [[FBSDKAccessToken currentAccessToken]tokenString];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection * connection, id result, NSError *error)
         {
             if (!error){
                 //NSLog(@"result: %@",result);
                 //NSLog(@"Location %@",[[result objectForKey:@"location"] objectForKey:@"name"]);
                 
                 Facebook = @{@"Birthday": [result valueForKey:@"birthday"],
                            @"Email": [result objectForKey:@"email"],
                            @"FBAccessToken": [[FBSDKAccessToken currentAccessToken]tokenString],
                            @"FirstName": [result objectForKey:@"first_name"],
                            @"Gender": [result objectForKey:@"gender"],
                            @"LastName": [result objectForKey:@"last_name"],
                            @"Link": [result objectForKey:@"link"],
                            @"Locale": [result objectForKey:@"locale"],
                            //@"Location": [[[result objectForKey:@"location"] objectForKey:@"location"] objectForKey:@"city"],
                            @"Name": [result objectForKey:@"name"],
                            @"UserName": [result valueForKey:@"id"]};
                 NSURL * urlImageProfileFB = [[NSURL alloc] initWithString:[[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"]];
                 UIImage * imageProfileFB = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlImageProfileFB]];
                 //NSLog(@"Facebook: %@",Facebook);
                 [_HUD removeFromSuperview];
                 Gestion * gestionView = [Gestion alloc];
                 [gestionView LoadFacebookInformation:Facebook whitImageProfile:imageProfileFB];
                 [self.navigationController pushViewController:gestionView animated:YES];
             }
             else {
                 NSLog(@"result: %@",[error description]);
                 [_HUD removeFromSuperview];
             }}];
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}
-(void)AuthorizeLocation
{
    self.myLocationManager = [[CLLocationManager alloc] init];
    
    if ([CLLocationManager locationServicesEnabled] )
    {
        self.myLocationManager.delegate = self;
        self.myLocationManager.distanceFilter = 1000;
        [self.myLocationManager requestAlwaysAuthorization];
        NSLog(@"Location Authorized");
        //[self.myLocationManager startUpdatingLocation];
    }
    else
    {
        _requestMessage = @"We Need Your Location to performance the TEST";
        [self ShowError];
    }
}

-(IBAction)ShowPrivacyPolitical:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://app.humandatamanager.com/private/user_data_policy.html"]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * systemLenguaje = [[NSLocale preferredLanguages]objectAtIndex:0];
    NSString * lenguage = [[[systemLenguaje componentsSeparatedByString:@"-"] objectAtIndex:0] uppercaseString];
    NSLog(@"%@",lenguage);
    if ([lenguage isEqualToString:@"ES"]) {
        TittleLb.text = @"Bienvenido a nuestro test, identifícate para empezar a conocernos";
        age.placeholder = @"Edad";
        sex.placeholder = @"Sexo M/F";
        city.placeholder = @"Ciudad, Provincia";
        email.placeholder = @"Correo";
        [polPrivLb setTitle:@"Aceptar la política de privacidad" forState:UIControlStateNormal] ;
        [Confirm setTitle:@"Confirmar" forState:UIControlStateNormal];
    }
    self.navigationController.navigationBar.hidden = YES;
    [[Confirm layer] setCornerRadius:3.0f];
    [[Confirm layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[Confirm layer] setBorderWidth:2.0];
    [self AuthorizeLocation];
    facebookLoginBut = [[FBSDKLoginButton alloc] init];
    
    NSArray * permissions = [[NSArray alloc] initWithObjects:@"public_profile", @"email",@"user_birthday", nil];
    facebookLoginBut.readPermissions = permissions;
    _gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTaps:)];
    [self.view addGestureRecognizer:_gestureTap];
    //Facebook = [NSDictionary alloc];
    
    if([FBSDKAccessToken currentAccessToken]){
        _HUD = [[MBProgressHUD alloc] init];
        _HUD.dimBackground = YES;
        _HUD.labelText = @"Cargando Datos de Facebook...";
        [self.view addSubview:_HUD];
        [self.view bringSubviewToFront:_HUD];
        [_HUD show:YES];
        FBSDKGraphRequest * request = [[FBSDKGraphRequest alloc]
                                       initWithGraphPath:[NSString stringWithFormat:@"me"]
                                       parameters:@{@"fields" : @"id,name,link,first_name,last_name,email,gender,locale,birthday,picture.width(100).height(100)"}
                                       HTTPMethod:@"GET"];
        _FBAccessToken = [[FBSDKAccessToken currentAccessToken]tokenString];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection * connection, id result, NSError *error)
         {
             if (!error){
                 NSLog(@"result: %@",result);
                 //NSLog(@"Location %@",[[result objectForKey:@"location"] objectForKey:@"name"]);
                 NSDictionary *userData = (NSDictionary *)result;
                 Facebook = @{@"Birthday": [result valueForKey:@"birthday"],
                              @"Email": [result objectForKey:@"email"],
                              @"FBAccessToken": [[FBSDKAccessToken currentAccessToken]tokenString],
                              @"FirstName": [result objectForKey:@"first_name"],
                              @"Gender": [result objectForKey:@"gender"],
                              @"LastName": [result objectForKey:@"last_name"],
                              @"Link": [result objectForKey:@"link"],
                              @"Locale": [result objectForKey:@"locale"],
                              //@"Location": userData[@"location"][@"county"],
                              @"Name": [result objectForKey:@"name"],
                              @"UserName": [result valueForKey:@"id"]};
                 NSURL * urlImageProfileFB = [[NSURL alloc] initWithString:[[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"]];
                 UIImage * imageProfileFB = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlImageProfileFB]];
                 NSLog(@"Facebook: %@",Facebook);
                 [_HUD removeFromSuperview];
                 Gestion * gestionView = [Gestion alloc];
                 [gestionView LoadFacebookInformation:Facebook whitImageProfile:imageProfileFB];
                 NSLog(@"Opening Gestion");
                 [self.navigationController pushViewController:gestionView animated:YES];
             }
             else {
                 NSLog(@"result: %@",[error description]);
                 [_HUD removeFromSuperview];
             }}];
    }

    // Do any additional setup after loading the view from its nib.
}

- (void)handleTaps:(UITapGestureRecognizer*)paramSender{
    NSUInteger touchCounter = 0;
    for (touchCounter = 0; touchCounter < paramSender.numberOfTouchesRequired; touchCounter++)
    {
        CGPoint touchPoint = [paramSender locationOfTouch:touchCounter inView:paramSender.view];
        NSLog(@"Touch #%lu: %@", (unsigned long)touchCounter+1, NSStringFromCGPoint(touchPoint));
        [self HideKeyBoard];
    }
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    
    CGRect frame = Confirm.frame;
    frame.origin.y = frame.origin.y + 61;
    facebookLoginBut.frame = frame;
    facebookLoginBut.delegate = self;
    [[facebookLoginBut layer]setCornerRadius:3.0f];
    [self.view addSubview:facebookLoginBut];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)ShowError
{
    [TSMessage showNotificationInViewController:self
                                          title:@"Error"
                                       subtitle:_requestMessage
                                          image:nil
                                           type:TSMessageNotificationTypeError
                                       duration:3.0
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
}

- (void)ShowSuccess
{
    [TSMessage showNotificationInViewController:self
                                          title:@"Informacion"
                                       subtitle:_requestMessage
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:3.0
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
}

-(void)HideKeyBoard
{
    [email resignFirstResponder];
    [age resignFirstResponder];
    [sex resignFirstResponder];
    [city resignFirstResponder];
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self HideKeyBoard];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self HideKeyBoard];
    return YES;
}
@end
