
#import "AppDelegate.h"
#import "GimbalFlurryAdapter.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GimbalFlurryAdapter sharedInstanceWithGimbalAPIKey:@"GIMBAL_API_KEY_HERE"
                                        andFlurryAPIKey:@"FLURRY_API_KEY_HERE"];
    [self localNotificationPermission];
    return YES;
}

# pragma mark - Local Notification Permission
- (void)localNotificationPermission {
    // this code will not work on iOS 7
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

@end
