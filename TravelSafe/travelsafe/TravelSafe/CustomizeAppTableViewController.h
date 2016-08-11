#import <UIKit/UIKit.h>
#import "AlertTableViewCell.h"
#import "Alert.h"
#import "AlertViewController.h"

@interface CustomizeAppTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

- (IBAction)addAlertButton:(id)sender;
@property NSMutableArray* arrayOfAlerts;
@property Alert* selectedAlert;
@property NSString* segueIdentifier;

@end
