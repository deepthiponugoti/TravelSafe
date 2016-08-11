#import "HomeScreenViewController.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController
@synthesize alertName, alertsDictionary, selectedAlert, destinationLabel, messageLabel, contactsArray, contactsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.alertName setDelegate:self];
    [self.messageLabel setDelegate:self];
    [self.destinationLabel setDelegate:self];
    [self.contactsTableView setDelegate:self];
    [self.contactsTableView setDataSource:self];
    selectedAlert = [Alert new];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    alertsDictionary = [self retrieveDataFromNSUserDefaults];
    NSLog(@"%lu", (unsigned long)[alertsDictionary count]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cutomizeAppAction:(id)sender {
    [self performSegueWithIdentifier:@"segue1" sender:self];
}

- (IBAction)startTrackingAction:(id)sender {
    if([self validateData]){
        
        //check if address is valid
        MKLocalSearchRequest* request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = destinationLabel.text;
        MKLocalSearch* search = [[MKLocalSearch alloc] initWithRequest:request];
        [search startWithCompletionHandler:^(MKLocalSearchResponse* response, NSError* error) {
            //selectedAlert.mapDestination = response.mapItems.firstObject;
            //check if destination is valid
            [self performSegueWithIdentifier:@"startTrackingSegue" sender:self];
        }];
    }
}

- (BOOL) validateData {
    if([destinationLabel.text isEqualToString:@""]){
        [self alertErrors:@"Destination cannot be empty."];
        return false;
    }
    /*
    if([messageLabel.text isEqualToString:@""]){
        [self alertErrors:@"Message cannot be empty"];
        return false;
    }
    if([contactsLabel.text isEqualToString:@""]){
        [self alertErrors:@"Contacts cannot be empty"];
        return false;

    }*/
    return true;
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

- (IBAction)showAlertsAction:(id)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an Alert" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    for(NSString* buttonTilte in [alertsDictionary allKeys]){
        [actionSheet addButtonWithTitle:buttonTilte];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString* alertSelectedKey = [popup buttonTitleAtIndex:buttonIndex];
    selectedAlert = [[alertsDictionary objectForKey:alertSelectedKey] copy];
    [self setOtherTitles];
}

- (void) setOtherTitles {
    [self clearAllTitles];
    alertName.text = selectedAlert.name;
    contactsArray = selectedAlert.contacts;
    [contactsTableView reloadData];
    
    //destinationLabel.text = selectedAlert.destination;
    messageLabel.text = selectedAlert.message;
    
}

-(void) clearAllTitles{
    alertName.text = @"";
    destinationLabel.text = @"";
    messageLabel.text = @"";
}

-(NSMutableDictionary*) retrieveDataFromNSUserDefaults {
    NSMutableDictionary *objectDictionary = [NSMutableDictionary new];
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedDict = [currentDefaults objectForKey:@"savedDictionary"];
    if (dataRepresentingSavedDict != nil)
    {
        NSMutableDictionary *oldSavedDict = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedDict];
        if (oldSavedDict != nil)
            objectDictionary = [[NSMutableDictionary alloc] initWithDictionary:oldSavedDict];
        else
            objectDictionary = [[NSMutableDictionary alloc] init];
    }
    return objectDictionary;
}

- (IBAction)showContactsAction:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    NSLog(@"am here. 1.");
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)displayPerson:(ABRecordRef)person
{
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyCompositeName(person);

    NSLog(@"%@", name);
    
    //phone number
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    
    //email kABPersonEmailProperty
    
    NSString* email = nil;
    ABMultiValueRef emailIds = ABRecordCopyValue(person,
                                                 kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailIds) > 0) {
        email = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(emailIds, 0);
    } else {
        email = @"[None]";
    }
    
    Person* contact = [Person new];
    contact.name = name;
    contact.phone = phone;
    contact.email = email;
    
    [contactsArray addObject:contact];
    [contactsTableView reloadData];
    
    CFRelease(phoneNumbers);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"startTrackingSegue"]) {
        TrackingViewController* vc = [segue destinationViewController];
        vc.selectedAlert = selectedAlert;
    }
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contactsArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contactCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Person* contact = [contactsArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = contact.name;
    
    if (indexPath.row % 2 == 1) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [contactsArray removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
}

@end
