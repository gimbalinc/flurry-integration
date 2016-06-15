#import <Foundation/Foundation.h>

@interface GimbalFlurryAdapter : NSObject

+ (instancetype) sharedInstanceWithGimbalAPIKey:(NSString *)gimbalAPIKey
                                andFlurryAPIKey:(NSString *)flurryAPIKey;

@end
