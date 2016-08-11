//
//  ContactTableViewCell.h
//  TravelSafe
//
//  Created by Kameswara sukesh Sista on 12/8/15.
//  Copyright © 2015 Ubiqts Computing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface ContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)deleteContact:(id)sender;
@property Person* contact;

@end
