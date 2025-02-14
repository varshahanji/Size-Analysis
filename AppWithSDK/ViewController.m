//
//  ViewController.m
//  VungleTestApp
//
//  Created by Varsha Hanji on 5/15/18.
//  Copyright © 2018 VarshaHanji. All rights reserved.
//

#import "ViewController.h"

static NSString *const kVungleTestAppID = @"5b4f8c61a6c77c747f4f1555";
static NSString *const kVungleTestPlacementID01 = @"FLEXVIEW-3516952";
static NSString *const kVungleTestPlacementID02 = @"VUNGLEREWARDED-7119220";
static bool isAdPlacement1Requested = false;
static bool isAdPlacement2Requested = false;

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onInitializeTapped:(id)sender {
    [self initializeSDK];
}
- (IBAction)onPlacementId1Tapped:(id)sender {
    isAdPlacement1Requested = true;
    [self requestAnAdWithPlacementId:kVungleTestPlacementID01];
}
- (IBAction)onPlacementId2Tapped:(id)sender {
    isAdPlacement2Requested = true;
    [self requestAnAdWithPlacementId:kVungleTestPlacementID02];
}

//Initializing Vungle SDK when user taps on InitializeSDK
- (void) initializeSDK{
    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError *error = nil;
    [sdk startWithAppId:kVungleTestAppID error:&error];
    [sdk setDelegate:self];
    [sdk setLoggingEnabled:NO];
}

// Requesting to load an ad when user requests for one from UI
-(void) requestAnAdWithPlacementId:(NSString *)plid{
    if (![[VungleSDK sharedSDK] isInitialized]) {
        [self popUpWithMessage:[NSString stringWithFormat:@"Please initialize SDK if you have not done it already. Please wait for SDK to be initialized! You should see a pop up when it is ready!"]];
        return;
    }
    NSError* error;
    [[VungleSDK sharedSDK] loadPlacementWithID:plid error:&error];
    if (error) {
        NSLog(@"Error encountered requesting ad : %@", error);
        [self popUpWithMessage:[NSString stringWithFormat:@"Error requesting playing ad : %@ for placementId : %@", error,plid]];
    }
}

//Play the ad when it is ready and requested by the user
-(void) playAd:(NSString *)plid{
    NSDictionary *options = @{VunglePlayAdOptionKeyOrientations: @(UIInterfaceOrientationMaskLandscape),
                              VunglePlayAdOptionKeyUser: @"userGameID",
                              VunglePlayAdOptionKeyIncentivizedAlertBodyText : @"If the video isn't completed you won't get your reward! Are you sure you want to close early?",
                              VunglePlayAdOptionKeyIncentivizedAlertCloseButtonText : @"Close",
                              VunglePlayAdOptionKeyIncentivizedAlertContinueButtonText : @"Keep Watching",
                              VunglePlayAdOptionKeyIncentivizedAlertTitleText : @"Careful!"};
    
    NSError *error;
    [[VungleSDK sharedSDK] playAd:self options:options placementID:plid error:&error];
    
    if (error) {
        NSLog(@"Error encountered playing ad: %@", error);
        [self popUpWithMessage:[NSString stringWithFormat:@"Error encountered playing ad: %@ for placementId : %@", error,plid]];
    }
}

//Implementing Callbacks
#pragma mark callbacks
- (void)vungleSDKDidInitialize{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self popUpWithMessage:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self popUpWithMessage:[NSString stringWithFormat:@"%s : %@",_cmd,error]];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID {
    NSLog(@"%s : %d", __PRETTY_FUNCTION__,isAdPlayable);
    
    if([placementID isEqualToString:kVungleTestPlacementID01] && isAdPlacement1Requested ){
        isAdPlacement1Requested = false;
        [self playAd:placementID];
    } else if([placementID isEqualToString:kVungleTestPlacementID02] && isAdPlacement2Requested ){
        isAdPlacement2Requested = false;
        [self playAd:placementID];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)vungleDidCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self popUpWithMessage:[NSString stringWithFormat:@"%s ViewInfo:%@ placementId:%@",_cmd,info,placementID]];

}

-(void) popUpWithMessage :(NSString *)msg{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"💁"
                                 message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
