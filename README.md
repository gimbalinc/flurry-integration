# Gimbal Flurry Integration #

This sample project shows how Gimbal can be integrated with [Flurry](https://dev.flurry.com).

In this integration information regarding Place events are sent to Flurry. You can than use this information from within Flurry's analytic tools.

## Setup ##

Please refer to the [hello-gimbal-ios](https://github.com/gimbalinc/hello-gimbal-ios) for generic Gimbal setup and dependencies.

You will need to enter your Gimbal API Key and Flurry API Key into the AppDelegate.m file.

## GimbalFlurryAdapter ##

To make integration easier we have created a helper class GimbalFlurryAdapter that exposes a simple method

```
#!objectc
+ (instancetype) sharedInstanceWithGimbalAPIKey:(NSString *)gimbalAPIKey
                                   flurryAPIKey:(NSString *)flurryAPIKey;
```

By invoking this method with the appropriate Gimbal and Flurry API keys both frameworks are initialized and place events are monitored and sent to Flurry.

The project is based on [hello-gimbal-ios](https://github.com/gimbalinc/hello-gimbal-ios) project. With the following changes

* Modified the [Podfile](https://bitbucket.org/gimbal/flurry-integration/src/bc6a227cdfce9f5df51fb8b9ef9d168286ff33b9/Podfile?fileviewer=file-view-default) to include Flurry's library.

* Added the [GimbalFlurryAdapter.h](https://bitbucket.org/gimbal/flurry-integration/src/ec90dd07169a2b91e338f87764b336b5e779578a/flurry-integration/GimbalFlurryAdapter.h?at=master&fileviewer=file-view-default) and [GimbalFlurryAdapter.m](https://bitbucket.org/gimbal/flurry-integration/src/ec90dd07169a2b91e338f87764b336b5e779578a/flurry-integration/GimbalFlurryAdapter.m?at=master&fileviewer=file-view-default) helper classes.

* Modified [AppDelegate](https://bitbucket.org/gimbal/flurry-integration/src/ec90dd07169a2b91e338f87764b336b5e779578a/flurry-integration/AppDelegate.m?at=master&fileviewer=file-view-default).didFinishLaunchingWithOptions to invoke GimbalFlurryAdapter.

The code for GimbalFlurryAdapter shows how Place events are sent to Flurry.


```
#!objectc

#import "GimbalFlurryAdapter.h"
#import "Flurry.h"
#import <Gimbal/Gimbal.h>

@interface GimbalFlurryAdapter() <GMBLPlaceManagerDelegate>

@property (nonatomic) GMBLPlaceManager *placeManager;

@end

@implementation GimbalFlurryAdapter

+ (instancetype) sharedInstanceWithGimbalAPUKey:(NSString *)gimbalAPIKey withFlurryAPIKey:(NSString *)flurryAPIKey
{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        [Flurry startSession:flurryAPIKey];
        [Gimbal setAPIKey:gimbalAPIKey options:nil];
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        self.placeManager = [GMBLPlaceManager new];
        self.placeManager.delegate = self;
        [GMBLPlaceManager startMonitoring];
        NSLog(@"GIMBAL and FLURRY initialized");
    }
    return self;
}

- (NSDictionary*)buildVisitParameters:(GMBLVisit *)visit
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"visitId" : visit.visitID,
                                                                                      @"placeId" : visit.place.identifier,
                                                                                      @"placeName" : visit.place.name}];
    
    for (NSString* key in [visit.place.attributes allKeys])
    {
        NSString* value = [visit.place.attributes stringForKey:key];
        [parameters setValue:value forKey:key];
    }
    
    return parameters;
}

# pragma mark - Gimbal Place Manager Delegate methods

- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit
{
    NSLog(@"Logging didBeginVisit to Flurry for %@", [visit description]);
    [Flurry logEvent:@"didBeginVisit" withParameters:[self buildVisitParameters:visit]];
}

- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit
{
    NSLog(@"Logging didEndVisit to Flurry for %@", [visit description]);
    [Flurry logEvent:@"didEndVisit" withParameters:[self buildVisitParameters:visit]];
}

@end

```