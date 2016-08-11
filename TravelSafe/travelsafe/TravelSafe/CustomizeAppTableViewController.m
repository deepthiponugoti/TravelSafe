#import "CustomizeAppTableViewController.h"

@interface CustomizeAppTableViewController ()

@end

@implementation CustomizeAppTableViewController
@synthesize arrayOfAlerts, selectedAlert, segueIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    arrayOfAlerts = [NSMutableArray arrayWithArray: [[self retrieveDataFromNSUserDefaults] allValues]];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"FirstTime"]) {
        UIAlertController* alert =
            [UIAlertController alertControllerWithTitle:@"Get Started"
                                                message:@"To get started, make a new alert. Saved alerts will show up here."
                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        [userDefaults setBool:YES forKey:@"FirstTime"];
        [userDefaults synchronize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayOfAlerts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[AlertTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"alertCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Alert* alert = [arrayOfAlerts objectAtIndex:indexPath.row];
    cell.nameOfAlert.text = alert.name;
    cell.typeOfAlert.text = alert.type;
    
    if (indexPath.row % 2 == 1) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

- (IBAction)addAlertButton:(id)sender {
    selectedAlert = nil;
    [self performSegueWithIdentifier:@"segue3" sender:self];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    selectedAlert = [arrayOfAlerts objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segue3" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AlertViewController* vc = [segue destinationViewController];
    vc.selectedAlert = selectedAlert;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteDataFromNSUserDefaults:[arrayOfAlerts objectAtIndex:indexPath.row]];
        [arrayOfAlerts removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData];
    }
}

- (void)deleteDataFromNSUserDefaults:(Alert *)alertToStore {
    NSMutableDictionary *objectDict = [NSMutableDictionary dictionaryWithDictionary:[self retrieveDataFromNSUserDefaults]];
    [objectDict removeObjectForKey:[NSString stringWithFormat:@"%@, %@", alertToStore.name, alertToStore.type]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver
                                                      archivedDataWithRootObject:objectDict] forKey:@"savedDictionary"];
}

@end
