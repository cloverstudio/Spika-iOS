//
//  HUServerListViewController.h
//  Spika
//
//  Created by Josip Marković on 27.03.2014..
//
//

#import "HUBaseViewController.h"

@protocol ServerListSelectionDelegate <NSObject>

-(void) addItemViewController:(id)controller didFinishEnteringItem:(NSString *)item;

@end

@interface HUServerListViewController : HUBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id <ServerListSelectionDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableViewServerList;
@property (weak, nonatomic) IBOutlet UITextField *addServerText;

@end
