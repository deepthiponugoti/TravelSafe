#import <UIKit/UIKit.h>
#import "Alert.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Person.h"
#import "ContactTableViewCell.h"
#import "TrackingViewController.h"

@interface AlertViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

- (IBAction)saveAlertAction:(id)sender;
- (IBAction)useAlertAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *nameOfAlertInput;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;


- (IBAction)showPicker:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *message;
@property NSMutableArray* contactsArray;

@property (weak, nonatomic) IBOutlet UISwitch *sendEmailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sendTextSwitch;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

@property Alert* selectedAlert;

@end
