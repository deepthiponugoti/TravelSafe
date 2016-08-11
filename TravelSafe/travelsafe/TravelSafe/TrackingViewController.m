#import "TrackingViewController.h"

@interface TrackingViewController ()

@end

@implementation TrackingViewController
@synthesize mapView, ettLabel, locationManager, route, selectedAlert, timeToReachInput, ett, loggedTime, currentLocation, originalLocation, timer, timeStationary, previousLocation, destinationInput, destination, rawDestination;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"inside tracking view controller.");
    
    [destinationInput setDelegate:self];
    [timeToReachInput setDelegate:self];
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate=self;
    
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    mapView.delegate = self;
    [mapView setShowsUserLocation:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [locationManager startUpdatingLocation];
    
    _alertCheckFlag = NO;
    _firstUpdate = YES;
    _update = YES;
    destination = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(toggleUpdate) userInfo:nil repeats:YES];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTracking];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
    NSLog(@"loc update");
    
    if (_firstUpdate) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 50000, 50000);
        [[self mapView] setRegion:viewRegion animated:YES];
        _firstUpdate = NO;
    }
    
    if (_update) {
        
        _update = NO;
        if (![rawDestination isEqualToString:destinationInput.text] && ![destinationInput.text isEqualToString:@""]) {
            rawDestination = destinationInput.text;
            MKLocalSearchRequest* request = [[MKLocalSearchRequest alloc] init];
            request.naturalLanguageQuery = rawDestination;
            MKLocalSearch* search = [[MKLocalSearch alloc] initWithRequest:request];
            [search startWithCompletionHandler:^(MKLocalSearchResponse* response, NSError* error) {
                destination = response.mapItems.firstObject;
            }];
        }
        if (destination == nil) return;
        
        MKDirectionsRequest *routeRequest = [[MKDirectionsRequest alloc] init];
        routeRequest.transportType = MKDirectionsTransportTypeAutomobile;
        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:currentLocation.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [routeRequest setSource:mapItem];
        [routeRequest setDestination:destination];
        
        MKDirections *routeDirections = [[MKDirections alloc] initWithRequest:routeRequest];
        [routeDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * routeResponse, NSError *routeError) {
            if (routeError) {
                NSLog(@"Error getting directions %@", routeError);
                return;
            } else {
                // The code doesn't request alternate routes, so add the single calculated route to
                // a previously declared MKRoute property called walkingRoute.
                
                NSLog(@"got directions");
                [mapView removeOverlay:route.polyline];
                
                self.route = routeResponse.routes.firstObject;
                ett = route.expectedTravelTime;
                [ettLabel setText:[NSString stringWithFormat:@"ETT: %i h %i m", ((int)ett / 3600), ((int)(ett/60) % 60)]];
                [mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
            }
            
            if(_alertCheckFlag){
                if(ett < 30) {
                    [self alertErrors:@"Reached before time"];
                    [self stopTracking];
                    return;
                }
                
                [self checkForAlerts];
            }
        }];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *line = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:line];
        routeRenderer.strokeColor = [UIColor blueColor];
        routeRenderer.alpha = 0.5;
        return routeRenderer;
    }
    else return nil;
}

- (IBAction)closeAppAndSendAlerts:(id)sender {
    loggedTime = [NSDate date];
    originalLocation = currentLocation;
    _alertCheckFlag = YES;
    [self minimizeApp];
}

- (IBAction)abortTrackingAndSendAlerts:(id)sender {
    [self stopTracking];
    if(selectedAlert.sendMessageFlag){
        [self sendTextMessage];
    }
    if(selectedAlert.sendEmailFlag){
        [self sendEmail];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) checkForAlerts {
    NSLog(@"inside checkForAlerts");
    //NSLog(@"%@", selectedAlert.type);
    if(!selectedAlert.type){
        if([timeToReachInput.text isEqualToString:@""]){
            [self lostAlgo];
        }else{
            [self lateAlgo];
        }
    }else if([@[@"Late", @"late"] containsObject:selectedAlert.type]){
        [self lateAlgo];
    }else if([@[@"Lost", @"lost"] containsObject:selectedAlert.type]){
        [self lostAlgo];
    }
}

-(void) lateAlgo {
    NSLog(@"Inside lateAlgo");
    if([self checkIfLate]){
        [self stopTracking];
        if(selectedAlert.sendMessageFlag){
            [self sendTextMessage];
        }
        if(selectedAlert.sendEmailFlag){
            [self sendEmail];
        }
    }
}

-(BOOL) checkIfLate {
    NSLog(@"inside checkIfLate");
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *timeToReach = [formatter dateFromString:timeToReachInput.text];
    if(timeToReach){
        NSTimeInterval timeToReachInSeconds = [timeToReach timeIntervalSinceReferenceDate] + 31600800;
        NSDate* expectedEta = [loggedTime dateByAddingTimeInterval:timeToReachInSeconds];
        
        if([[NSDate dateWithTimeIntervalSinceNow:ett-60] compare:expectedEta] == NSOrderedDescending){
            NSLog(@"You are late dude..!!");
            return YES;
        }
        
        return NO;
    } else {
        [self alertErrors:@"Date entered is of wrong format: eg:HH:mm"];
        _alertCheckFlag = NO;
        return NO;
    }
}


-(void) lostAlgo {
    NSLog(@"checking if you are lost");
    if([self checkIfLost]){
        if(selectedAlert.sendMessageFlag){
            [self stopTracking];
            [self sendTextMessage];
        }
        if(selectedAlert.sendEmailFlag){
            [self stopTracking];
            [self sendEmail];
        }
    }
}

-(BOOL) checkIfLost {
    double routeDistance = [originalLocation distanceFromLocation:destination.placemark.location];
    double currentDistance = [originalLocation distanceFromLocation:currentLocation] + [destination.placemark.location distanceFromLocation:currentLocation];
    if (currentDistance > routeDistance * 1.25 + 300) {
        NSLog(@"You are Lost!");
        return YES;
    }
    
    if (previousLocation) {
        NSTimeInterval timeDelta = [currentLocation.timestamp timeIntervalSinceDate:previousLocation.timestamp];
        CLLocationDistance distanceDelta = [currentLocation distanceFromLocation:previousLocation];
        double speed = distanceDelta / timeDelta;
        NSLog(@"%f", speed);
        if (speed > 7) {
            timeStationary = 0;
        } else {
            timeStationary += timeDelta;
            NSLog(@"%f", timeStationary);
            if (timeStationary > 600) return YES;
        }
    }
    previousLocation = currentLocation;
    return NO;
}

-(void) sendTextMessage {
    for (Person* contact in selectedAlert.contacts) {
        if ([contact.phone isEqualToString:@"[None]"]) continue;
        
        NSLog(@"sending text message");
        
        NSString*  twilioSID = @"ACa9d69206bdebe8bd9525f8caa35133b2";
        NSString*  twilioSecret = @"8853765c4ca5616384e8ff1a0a87e9a1";
        NSString*  fromNumber = @"%2B12819035320";
        NSString*  toNumber = contact.phone; // replace with alert.mobileNumber
        
        NSString*  message = selectedAlert.message;
        NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages", twilioSID, twilioSecret, twilioSID];
        
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod: @"POST"];
        
        NSString *bodyString = [NSString stringWithFormat:@"From=%@&To=%@&Body=%@", fromNumber, toNumber, message];
        NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
        NSError *error;
        NSURLResponse *response;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // Handle the received data
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"Request sent. %@", receivedString);
        }
    }
}


-(void) sendEmail {
    for (Person* contact in selectedAlert.contacts) {
        if ([contact.email isEqualToString:@"[None]"]) continue;
        
        NSLog(@"sending email");
        
        NSString* user = @"api";
        NSString* pass = @"key-88ab0e0d3e8581ba0dde900495bcf6ca";
        NSString* from = @"TravelSafe <mailgun@sandbox57db7b4523024b08ace2f9dd393b1774.mailgun.org>";
        NSString* to = contact.email;
        NSString* subject = [NSString stringWithFormat: @"%@ Travel Alert", selectedAlert.type];
        NSString* text = selectedAlert.message;
        
        NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.mailgun.net/v3/sandbox57db7b4523024b08ace2f9dd393b1774.mailgun.org/messages", user, pass];
        
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod: @"POST"];
        
        NSString *bodyString = [NSString stringWithFormat:@"from=%@&to=%@&subject=%@&text=%@", from, to, subject, text];
        NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
        NSError *error;
        NSURLResponse *response;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // Handle the received data
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"Request sent. %@", receivedString);
        }
    }
}

-(void) minimizeApp {
    [NSThread detachNewThreadSelector:NSSelectorFromString(@"suspend") toTarget:[UIApplication sharedApplication] withObject:nil];
}

-(void) toggleUpdate {
    NSLog(@"toggling update");
    _update = !_update;
}

-(void) stopTracking {
    [timer invalidate];
    [locationManager stopUpdatingLocation];
}

-(void)alertErrors:(NSString *)errorMessage {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}



-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
