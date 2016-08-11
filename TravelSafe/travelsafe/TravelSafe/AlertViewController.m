#import "AlertViewController.h"

@interface AlertViewController ()
{
}
@end

@implementation AlertViewController
@synthesize nameOfAlertInput, contactsArray, message, typeSegmentedControl, sendEmailSwitch, sendTextSwitch, contactsTableView, selectedAlert;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.nameOfAlertInput setDelegate:self];
    [self.message setDelegate:self];
    [self.contactsTableView setDelegate:self];
    [self.contactsTableView setDataSource:self];
    contactsArray = [NSMutableArray new];
    message.text = @"";
    [typeSegmentedControl setSelectedSegmentIndex:0];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (selectedAlert != nil) {
        nameOfAlertInput.text = selectedAlert.name;
        if ([selectedAlert.type isEqualToString:@"Late"])
            [typeSegmentedControl setSelectedSegmentIndex:0];
        else
            [typeSegmentedControl setSelectedSegmentIndex:1];
        contactsArray = selectedAlert.contacts;
        message.text = selectedAlert.message;
        [sendEmailSwitch setOn:selectedAlert.sendEmailFlag];
        [sendTextSwitch setOn:selectedAlert.sendMessageFlag];
    }
}

- (IBAction)saveAlertAction:(id)sender {
    Alert* alert = [[Alert alloc] init];
    alert.name = nameOfAlertInput.text;
    alert.type = [typeSegmentedControl titleForSegmentAtIndex:[typeSegmentedControl selectedSegmentIndex]];
    alert.contacts = contactsArray;
    alert.message = message.text;
    alert.sendEmailFlag = sendEmailSwitch.on;
    alert.sendMessageFlag = sendTextSwitch.on;
    
    if([self isAlertValid]){
        [self storeDataInNSUserDefaults:alert];
        //[self performSegueWithIdentifier:@"segue4" sender:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(BOOL) isAlertValid {
    if([nameOfAlertInput.text isEqualToString:@""]){
        [self alertErrors:@"Alert name cannot be empty."];
        return false;
    }
    return true;
}

- (void)storeDataInNSUserDefaults:(Alert *)alertToStore {
    NSMutableDictionary *objectDict = [NSMutableDictionary dictionaryWithDictionary:[self retrieveDataFromNSUserDefaults]];
    [objectDict setObject:alertToStore forKey:[NSString stringWithFormat:@"%@, %@", alertToStore.name, alertToStore.type]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver
                                                      archivedDataWithRootObject:objectDict] forKey:@"savedDictionary"];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (IBAction)showPicker:(id)sender {
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    NSLog(@"am here. 1.");
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
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
    
    //CFRelease(phoneNumbers);
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

- (IBAction)useAlertAction:(id)sender {
    Alert* alert = [[Alert alloc] init];
    alert.name = nameOfAlertInput.text;
    alert.type = [typeSegmentedControl titleForSegmentAtIndex:[typeSegmentedControl selectedSegmentIndex]];
    alert.contacts = contactsArray;
    alert.message = message.text;
    alert.sendEmailFlag = sendEmailSwitch.on;
    alert.sendMessageFlag = sendTextSwitch.on;
    selectedAlert = alert;
    
    [self performSegueWithIdentifier:@"startTrackingSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"startTrackingSegue"]) {
        TrackingViewController* vc = [segue destinationViewController];
        vc.selectedAlert = selectedAlert;
    }
}

@end
