#import "Person.h"

@implementation Person
@synthesize name, phone, email;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super init] ) {
        self.name = [aDecoder decodeObjectForKey:@"nameofperson"];
        self.phone = [aDecoder decodeObjectForKey:@"phoneofperson"];
        self.email = [aDecoder decodeObjectForKey:@"emailofperson"];
    }
    return self;
}
// give a key for each object you store
-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:name forKey:@"nameofperson"];
    [aCoder encodeObject:phone forKey:@"phoneofperson"];
    [aCoder encodeObject:email forKey:@"emailofperson"];
}


@end
