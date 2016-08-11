#import <UIKit/UIKit.h>
#import "Alert.h"
#import "Person.h"
#import <MessageUI/MessageUI.h>

@import MapKit;
@import CoreLocation;

@interface TrackingViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *ettLabel;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) Alert* selectedAlert;
@property (strong, nonatomic) MKRoute* route;
@property BOOL update;
@property BOOL firstUpdate;
@property (weak, nonatomic) IBOutlet UITextField *destinationInput;
@property (weak, nonatomic) IBOutlet UITextField *timeToReachInput;
- (IBAction)closeAppAndSendAlerts:(id)sender;
- (IBAction)abortTrackingAndSendAlerts:(id)sender;

@property NSString* rawDestination;
@property MKMapItem* destination;
@property BOOL alertCheckFlag;
@property NSTimeInterval ett;
@property NSDate* loggedTime;
@property CLLocation* currentLocation;
@property CLLocation* originalLocation;
@property NSTimer* timer;
@property NSTimeInterval timeStationary;
@property CLLocation* previousLocation;
@end
