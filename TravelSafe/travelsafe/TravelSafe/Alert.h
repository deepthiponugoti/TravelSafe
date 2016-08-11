#import <Foundation/Foundation.h>
@import MapKit;
@import CoreLocation;

@interface Alert : NSObject <NSCoding, NSCopying>

@property NSString* name;
@property NSString* type;
@property NSString* message;
@property NSMutableArray* contacts;
@property BOOL sendEmailFlag;
@property BOOL sendMessageFlag;

@end
