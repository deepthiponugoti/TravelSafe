#import "Alert.h"

@implementation Alert
@synthesize name, type, message, contacts, sendMessageFlag, sendEmailFlag;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super init] ) {
        self.name = [aDecoder decodeObjectForKey:@"nameOfAlert"];
        self.type = [aDecoder decodeObjectForKey:@"typeOfAlert"];
        self.message = [aDecoder decodeObjectForKey:@"messageOfAlert"];
        self.contacts = [aDecoder decodeObjectForKey:@"contactsOfAlert"];
        self.sendEmailFlag = [aDecoder decodeBoolForKey:@"sendEmailFlag"];
        self.sendMessageFlag = [aDecoder decodeBoolForKey:@"sendMessageFlag"];
    }
    return self;
}
// give a key for each object you store
-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:name forKey:@"nameOfAlert"];
    [aCoder encodeObject:type forKey:@"typeOfAlert"];
    [aCoder encodeObject:message forKey:@"messageOfAlert"];
    [aCoder encodeObject:contacts forKey:@"contactsOfAlert"];
    [aCoder encodeBool:sendEmailFlag forKey:@"sendEmailFlag"];
    [aCoder encodeBool:sendMessageFlag forKey:@"sendMessageFlag"];
}

- (id)copyWithZone:(NSZone *)zone {
    Alert* copy = [[Alert alloc] init];
    copy.name = [name copy];
    copy.type = [type copy];
    copy.message = [message copy];
    copy.contacts = [contacts mutableCopy];
    copy.sendEmailFlag = sendEmailFlag;
    copy.sendMessageFlag = sendMessageFlag;
    return copy;
}

@end
