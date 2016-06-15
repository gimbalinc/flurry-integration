#import "GimbalFlurryAdapter.h"
#import "Flurry.h"
#import <Gimbal/Gimbal.h>

@interface GimbalFlurryAdapter() <GMBLPlaceManagerDelegate>

@property (nonatomic) GMBLPlaceManager *placeManager;

@end

@implementation GimbalFlurryAdapter

+ (instancetype) sharedInstanceWithGimbalAPIKey:(NSString *)gimbalAPIKey
                                andFlurryAPIKey:(NSString *)flurryAPIKey
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
    NSLog(@"Logging didBeginVisit to Flurry for %@", [visit description]);
    [Flurry logEvent:@"didEndVisit" withParameters:[self buildVisitParameters:visit]];
}

@end
