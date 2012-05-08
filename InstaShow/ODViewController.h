//
//  ODViewController.h
//  InstaShow
//
//  Created by In|Ce Saiaram on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"

@interface ODViewController : UIViewController <UITableViewDataSource>
{
    NSArray *dataArray;
}
@property (nonatomic,strong) NSDictionary *jsonData;
@property (nonatomic,weak) IBOutlet UITableView *photoGridTableView;
@end
