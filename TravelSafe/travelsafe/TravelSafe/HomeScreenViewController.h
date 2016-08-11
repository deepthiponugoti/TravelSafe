#import <UIKit/UIKit.h>
#import "Alert.h"
#import "Person.h"
#import <AddressBookUI/AddressBookUI.h>
#import "TrackingViewController.h"
#import "ContactTableViewCell.h"

@import MapKit;
@import CoreLocation;

@interface HomeScreenViewController : UIViewController<UIActionSheetDelegate, ABPeoplePickerNavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

//actions
- (IBAction)cutomizeAppAction:(id)sender;
- (IBAction)startTrackingAction:(id)sender;
- (IBAction)showAlertsAction:(id)sender;
- (IBAction)showContactsAction:(id)sender;

//labels
@property (weak, nonatomic) IBOutlet UITextField *alertName;
@property (weak, nonatomic) IBOutlet UITextField *destinationLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageLabel;

//properties
@property NSMutableArray* contactsArray;
@property NSMutableDictionary* alertsDictionary;
@property Alert* selectedAlert;

@end
